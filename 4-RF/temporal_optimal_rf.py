# Temporal-optimal random forest
#
# The other temporal scales follow the same procedure: the same 80/20 split (random_state=42), the same hyperparameter search space, and 5-fold cross-validation, each retaining its own search result.
# Sample tables: autumn_samples.xlsx, winter_samples.xlsx, spring_samples.xlsx, summer_samples.xlsx, sampling_month_samples.xlsx, annual_samples.xlsx.
# This script evaluates only the temporal-optimal scale, temporal_optimal_samples.xlsx.
# temporal_optimal_rf.pkl is the retained hyperparameter-search model for this scale.

from pathlib import Path

import numpy as np
import pandas as pd
import joblib
import matplotlib.pyplot as plt
from scipy.stats import randint, uniform
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split, RandomizedSearchCV
from sklearn.metrics import (
    r2_score,
    mean_absolute_error,
    mean_squared_error,
    explained_variance_score,
)
from sklearn.pipeline import Pipeline


def lin_ccc(y_true, y_pred):
    y_true = np.asarray(y_true, dtype=float)
    y_pred = np.asarray(y_pred, dtype=float)
    cov_xy = np.cov(y_true, y_pred, bias=True)[0, 1]
    var_x = np.var(y_true)
    var_y = np.var(y_pred)
    mean_x = np.mean(y_true)
    mean_y = np.mean(y_pred)
    return (2 * cov_xy) / (var_x + var_y + (mean_x - mean_y) ** 2)


def main():
    root = Path(__file__).resolve().parents[1]
    data_path = root / "1-data" / "temporal_optimal_samples.xlsx"
    model_path = Path(__file__).resolve().parent / "temporal_optimal_rf.pkl"

    data = pd.read_excel(data_path)
    X = data.iloc[:, :-1]
    y = data.iloc[:, -1]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    print("samples", len(y), "train", len(y_train), "test", len(y_test))
    print("features", list(X.columns))

    # Hyperparameter search settings: 5-fold cross-validation on the training set with 10 randomly drawn parameter sets. Only the search space is specified here, and the already trained model is loaded.
    pipe = Pipeline([("rf", RandomForestRegressor())])
    param_distributions = {
        "rf__n_estimators": randint(50, 200),
        "rf__max_depth": randint(5, 20),
        "rf__min_samples_split": randint(2, 10),
        "rf__min_samples_leaf": randint(1, 5),
        "rf__max_features": uniform(0.5, 0.5),
    }
    search = RandomizedSearchCV(pipe, param_distributions, n_iter=10, cv=5)
    print(search)

    model = joblib.load(model_path)
    rf = model.named_steps["rf"]
    kept = {
        "n_estimators": rf.n_estimators,
        "max_depth": rf.max_depth,
        "max_features": float(rf.max_features),
        "min_samples_split": rf.min_samples_split,
        "min_samples_leaf": rf.min_samples_leaf,
        "random_state": rf.random_state,
    }
    print("retained hyperparameters")
    for key, value in kept.items():
        print(f"  {key}: {value}")

    y_train_pred = model.predict(X_train)
    y_test_pred = model.predict(X_test)
    rows = []
    for label, y_true, y_pred in [
        ("Training", y_train, y_train_pred),
        ("Testing", y_test, y_test_pred),
    ]:
        rows.append(
            {
                "Set": label,
                "R2": r2_score(y_true, y_pred),
                "MAE": mean_absolute_error(y_true, y_pred),
                "RMSE": np.sqrt(mean_squared_error(y_true, y_pred)),
                "LCCC": lin_ccc(y_true, y_pred),
                "Evar": explained_variance_score(y_true, y_pred),
            }
        )
    metrics = pd.DataFrame(rows)
    print(metrics.round(3).to_string(index=False))

    fig, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(y_train, y_train_pred, c="red", alpha=0.45, marker="o", s=60, label="Training")
    ax.scatter(y_test, y_test_pred, c="green", alpha=0.7, marker="^", s=70, label="Testing")
    low = min(y.min(), y_train_pred.min(), y_test_pred.min())
    high = max(y.max(), y_train_pred.max(), y_test_pred.max())
    ax.plot([low, high], [low, high], color="black", linewidth=1)
    ax.set_xlabel("Observed SOC")
    ax.set_ylabel("Predicted SOC")
    ax.legend()
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()
