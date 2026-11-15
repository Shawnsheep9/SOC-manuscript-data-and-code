# Data and code

Data and code for the temporal-optimal random forest model of soil organic carbon in Hengnan County. The six temporal scales are autumn, winter, spring, summer, the annual scale, and the sampling month. The random forest also uses a temporal-optimal sample that combines summer climate with winter land-surface variables.

```text
Data and code/
├── 1-Data/                          Random forest samples (135 rows, 15 predictors + soil organic carbon)
│   ├── autumn_samples.xlsx
│   ├── winter_samples.xlsx
│   ├── spring_samples.xlsx
│   ├── summer_samples.xlsx
│   ├── annual_samples.xlsx
│   ├── sampling_month_samples.xlsx
│   └── temporal_optimal_samples.xlsx
├── 2-OPGD/                          Optimal-parameters geographical detector
│   ├── input -OPGD/                 Detector inputs for six scales (Y + X1–X24)
│   ├── GD.R                         Factor detector
│   └── output-results/
│       └── OPGD-Results.xlsx        q values for each scale; manuscript Table 3
├── 3-PSEM/                          Piecewise structural equation model
│   ├── input -PSEM/                 SEM inputs for six scales
│   ├── SEM_model_autumn.R           Autumn model
│   ├── SEM_model_others.R           Model used for the other scales
│   └── SEM-results.xlsx             Standardized path coefficients; manuscript Table 4
└── 4-RF/                            Temporal-optimal random forest
    ├── temporal_optimal_rf.py       Loads the retained model and reports accuracy
    └── temporal_optimal_rf.pkl      Retained model for the temporal-optimal scale
```

Columns shared by `1-Data` and the geographical detector have identical values. The detector inputs also include wind speed, land surface temperature, NIRV, curvature, total potassium, bulk density, population, and nighttime lights. In `temporal_optimal_samples.xlsx`, temperature and precipitation come from summer, and NDVI, EVI, and SAVI come from winter.

`GD.R` currently reads `input data for OPGD/annual_samples_opgd.csv`. The input folder is now named `input -OPGD`, so change the path before running. For the other scales, replace the file name with `autumn_samples_opgd.csv`, `winter_samples_opgd.csv`, `spring_samples_opgd.csv`, `summer_samples_opgd.csv`, or `sampling_month_samples_opgd.csv`.

`SEM_model_autumn.R` is used only for autumn and reads `input -PSEM/autumn_samples_sem.csv`. Winter, spring, summer, the annual scale, and the sampling month use `SEM_model_others.R`. That script currently reads `sampling_month_samples_sem.csv`; replace it with `winter_samples_sem.csv`, `spring_samples_sem.csv`, `summer_samples_sem.csv`, or `annual_samples_sem.csv` for the other scales. Set the working directory to `3-PSEM`. Clay is not included in the soil composite.

`temporal_optimal_rf.py` evaluates only the temporal-optimal scale. The other scales use the same 80/20 split (`random_state = 42`), the same hyperparameter search space, and 5-fold cross-validation, each retaining its own search result.
