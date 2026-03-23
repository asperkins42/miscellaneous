# CICIoT2023 Edge Anomaly Detection — Project Walkthrough

## 1. The Problem

We were given the **CICIoT2023** dataset from the Canadian Institute for Cybersecurity — a modern, labeled IoT network traffic dataset containing 7.8 million rows of extracted network flow features. Each row represents one network conversation and is labeled as either normal (`BenignTraffic`) or one of 34 attack types (DDoS, DoS, Mirai, reconnaissance, injection attacks, etc.).

The goal was to train a **lightweight anomaly detection model** that could be deployed to a resource-constrained edge device (Raspberry Pi-class), balancing detection accuracy against energy efficiency.

---

## 2. Key Design Decisions

### 2.1 Binary vs. Multiclass Framing

The most consequential early decision was **how to frame the problem**.

The dataset has 35 classes (34 attacks + benign). A naive approach would train a 35-class classifier. We chose **binary classification** instead:

- `0` = `BenignTraffic`
- `1` = any attack

**Why this matters:**
- A smaller output layer (sigmoid vs. softmax over 35 nodes) means fewer parameters and faster inference
- The edge device's job is to *raise an alert*, not to categorize the attack — that's a job for a backend system
- The class imbalance is extreme: `Uploading_Attack` has only 140 samples out of 5.5 million. In multiclass framing it is essentially unlearnable. In binary framing, those 140 samples are simply folded into the "attack" class where the model handles them via class weighting
- Binary framing exposes a **single probability threshold** that can be tuned post-deployment based on the operator's acceptable false-positive rate

### 2.2 Why Not SVM?

The user specifically asked about SVM. It was excluded for two reasons:

1. **Training cost**: RBF-SVM has O(n²) complexity. On 5.5 million samples, this is computationally infeasible. Linear SVM is feasible but still requires many full passes over the data.
2. **Deployment cost**: SVM inference requires computing a dot product against every support vector. With potentially tens of thousands of support vectors, this is slower than a small decision tree and produces a larger model file.

LightGBM strictly dominates SVM on both dimensions for this use case.

### 2.3 Why Not Random Forest?

Random Forest was excluded as a *primary* recommendation (though it was discussed) because:
- 50 trees × depth 8 ≈ 500 KB serialized — larger than LightGBM for equivalent accuracy
- Inference requires traversing all trees independently (no early stopping within a tree)
- LightGBM achieves comparable or better accuracy at roughly ¼ the model size

### 2.4 Energy Proxy Metric

We can't directly measure joules on a simulated device, so we used two **proxies** that are tightly correlated with energy consumption on edge hardware:

1. **Per-sample inference latency (µs)** — CPU time × clock speed × voltage ≈ energy per inference
2. **Serialized model size (KB)** — determines how much of the model fits in cache; cache misses cost energy

These are standard proxies in edge ML research literature.

---

## 3. Dataset Characteristics Worth Noting

### 3.1 Severe Class Imbalance

| Class | Count | % of Train |
|---|---|---|
| DDoS-ICMP_Flood | 848,088 | 15.4% |
| BenignTraffic | 129,538 | 2.4% |
| Uploading_Attack | 140 | 0.003% |

The attack-to-benign ratio is **41.4:1**. This has real consequences:
- A model that predicts "attack" for every sample gets 97.6% accuracy — a completely useless model
- **This is why we never use raw accuracy as our primary metric.** We prioritize **Recall (attack class)** — the fraction of actual attacks correctly flagged. A missed attack (false negative) is far more costly than a false alarm (false positive)
- All models were configured with `class_weight='balanced'` or `scale_pos_weight=41.4` for LightGBM, which internally up-weights the minority (benign) class during training

### 3.2 Constant Columns

12 of the 46 feature columns are **zero-variance** — they hold the same value for every single row across all 7.8 million records. These include `IPv`, `LLC`, and several protocol flag columns that were always zero in the capture environment. `VarianceThreshold` automatically identifies and removes them, reducing the feature space from 46 → 34 features. This is important for edge deployment: fewer features = smaller model, less computation per inference.

---

## 4. The Pipeline Architecture

The entire pipeline lives in a single script: `edge_anomaly_pipeline.py`. Here's what each section does and why it was designed that way.

### 4.1 Chunked Data Loading

```python
pd.read_csv(path, chunksize=200_000, dtype='float32', converters={LABEL_COL: str})
```

Two significant choices here:
- **`dtype='float32'`** halves memory usage compared to default float64 (1.6 GB → 0.94 GB for the training set). The precision loss is irrelevant for tree-based models and negligible for the MLP
- **`chunksize=200_000`** keeps peak memory predictable and future-proofs the code for deployment on the Pi itself, where loading a 1.6 GB file in one shot might fail

### 4.2 Preprocessing Pipeline

```
VarianceThreshold → StandardScaler → (optional) LightGBM Feature Selection
```

The preprocessor is **fit only on training data** and then applied identically to validation and test sets. This is a critical discipline — fitting the scaler on the full dataset (including test) would constitute *data leakage* and produce falsely optimistic evaluation results.

The preprocessor is saved separately as `preprocessor.joblib` so that at inference time on the Pi or Arduino, raw features can be transformed identically to how they were transformed during training.

### 4.3 Model Selection

Six models were trained, chosen to span a range of the accuracy-vs-size tradeoff:

| Model | Design Philosophy |
|---|---|
| `LogisticRegression` | Linear baseline — establishes the floor. If a linear model gets 99% F1, we know the problem is linearly separable and don't need complexity |
| `DecisionTree_d10/d14` | Single tree — ultra-fast inference (a chain of if/else comparisons), extremely small, can be compiled to pure C |
| `LightGBM_tiny` | **Primary target** — 50 shallow trees, fits in ARM L2 cache, tree traversal is cache-friendly |
| `LightGBM_d6` | Higher accuracy — 200 trees with early stopping; the model we'd use if the Pi has spare capacity |
| `MLP_small` | Neural network — 44→32→16→1 architecture; small enough to export as C arrays for Arduino |

### 4.4 LightGBM Early Stopping

LightGBM was configured with `eval_set=[(X_val, y_val)]` and `early_stopping(stopping_rounds=20)`. This means:
- Training stops as soon as validation loss stops improving for 20 consecutive rounds
- The nominal `n_estimators=200` is a ceiling, not a target — the actual number of trees built is determined by the data
- This prevents overfitting and saves training time automatically

### 4.5 Evaluation Metrics

We track five detection metrics and three edge metrics per model:

**Detection:**
- **Accuracy** — reported but deprioritized due to class imbalance
- **Precision** — fraction of predicted attacks that are real (false positive rate)
- **Recall** — fraction of real attacks caught (false negative rate) — **primary metric**
- **F1** — harmonic mean of precision and recall; used for ranking models
- **AUC-ROC** — threshold-independent measure of discriminative ability

**Edge efficiency:**
- `model_size_kb` — compressed joblib file size
- `inference_us_single` — median of 1,000 single-sample predictions in microseconds
- `inference_ms_batch1k` — single prediction call over 1,000 samples (amortized cost)

### 4.6 Threshold Tuning

The MLP (and all models with `predict_proba`) outputs a **probability**, not a hard label. The default threshold of 0.5 is arbitrary. We sweep thresholds from 0.05 to 0.90 on the **validation set** (not test) and find the value that maximizes recall while keeping precision above 0.90.

The optimal threshold found was **0.05** — meaning the model flags a flow as an attack if the predicted attack probability exceeds 5%. This sounds aggressive but reflects the cost asymmetry: a missed attack is far worse than a false alarm in an IDS context. The 0.05 threshold is saved alongside the model and used at inference time.

> **Significant note**: This threshold was tuned on the validation set, which is why we have a three-way train/validation/test split. If we had tuned the threshold on the test set, we would be making a prediction decision using test data, which invalidates the reported metrics.

---

## 5. The Models in Practice

The smoke test (5,000 training rows, 1,000 test rows) confirmed the pipeline works and gave us a preview of relative performance:

| Model | F1 | Size | Inf (µs) |
|---|---|---|---|
| LightGBM_tiny | 0.990 | 15.6 KB | 418 µs |
| DecisionTree_d10 | 0.984 | 1.3 KB | 33 µs |

Note that the Decision Tree was **10× faster** at inference but slightly lower F1. On a full training run with 5.5M samples, both models will improve substantially — the Decision Tree in particular benefits greatly from more data to establish its splits.

The **LightGBM_tiny** was selected as the primary recommendation because:
- It requires no feature scaling at inference (trees are scale-invariant) — one fewer preprocessing step on the edge device
- Its inference pattern (tree traversal) is cache-friendly on ARM processors
- At ~80 KB serialized on a full training run, it fits comfortably in the Pi's L2 cache
- It natively handles class imbalance via `scale_pos_weight`

---

## 6. Edge Deployment

### 6.1 Raspberry Pi (`pi_inference.py`)

The Pi path is straightforward because it runs Linux and Python. The three files needed are:
1. `preprocessor.joblib` — the fitted VarianceThreshold + StandardScaler
2. `MLP_small_best.joblib` (or whichever model was exported)
3. `MLP_small_threshold.txt` — the optimal decision threshold

The inference script supports three modes: demo (pull rows from test CSV), file batch (classify a CSV of flows), and stdin (pipe a single comma-separated row). In production the stdin/file modes would be replaced by a live network tap feeding feature vectors.

**Important**: The Pi does not need the training data or the full pipeline script — only the three artifact files and `pi_inference.py`. This separation of training from inference is deliberate.

### 6.2 Arduino (`arduino_export.py` + `arduino/`)

The Arduino path is fundamentally different and significantly more involved. Arduinos (with the exception of very new boards) have no operating system, no Python interpreter, and often only a few KB of SRAM. The approach used here is:

1. **Extract** the MLP's weights, biases, scaler mean/std, and feature mask as Python numpy arrays
2. **Render** them as C array literals with the `PROGMEM` attribute — this places them in flash memory instead of SRAM, which is critical since the weight arrays alone (1,985 × 4 bytes = ~7.9 KB) would exhaust the SRAM of many boards
3. **Implement** a from-scratch forward pass in C: `preprocess()` (mask + scale) → `mlp_predict()` (matrix multiply + sigmoid)
4. **Generate** a complete `.ino` sketch that wraps this in a Serial interface

The generated `anomaly_model.h` is fully self-contained — no ML framework, no Python, no external library is needed on the Arduino. The entire inference chain is a few dozen lines of C reading from PROGMEM.

**Significant hardware note**: A standard Arduino Uno has 32 KB of flash and 2 KB of SRAM. The weight arrays alone require ~7.9 KB of flash plus the sketch code — this exceeds the Uno's capacity. Compatible boards include the **Nano 33 BLE** (1 MB flash), **Mega 2560** (256 KB flash), **Due** (512 KB), and **Portenta H7** (2 MB). This is why model size matters so much for true embedded deployment.

If the target were a Uno, the right model would be the `DecisionTree_d10`, which at ~1.3 KB (smoke test) would fit easily and could be converted to a pure C switch-statement with no array math at all.

---

## 7. What Could Be Improved

A few things were noted as out of scope but worth flagging for future work:

- **The `Uploading_Attack` class (140 samples)**: Even in binary framing this attack type is so rare that a model seeing it for the first time at test time may behave unpredictably. SMOTE or data augmentation for this class would help in a multiclass extension.
- **Feature correlation**: `Rate` and `Srate` showed very similar ranges in initial sampling — they may be near-perfectly correlated. Removing one could shrink the model without hurting accuracy.
- **Quantization**: The MLP weights are stored as `float32`. Quantizing to `int8` (post-training quantization via TensorFlow Lite) would cut the weight size by 4× and speed up inference on ARM processors that have 8-bit SIMD units — a significant win for a production deployment.
- **Live feature extraction**: The pipeline assumes pre-extracted network flow features. In a real deployment, something like `nDPI` or `CICFlowMeter` would need to run on the Pi/Arduino to extract the 46 features from raw packets — that integration is not covered here.
