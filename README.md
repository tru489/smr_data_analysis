# smr_data_analysis

MATLAB code for analyzing SMR data,
including buoyant mass measurements, density/volume from density trapping, water
content, and paired SMR + fluorescence (PMT) exclusion data.

The pipeline reads raw binary frequency/time data acquired from the resonator,
detects single-cell transit peaks, fits and curates them, applies calibration,
and writes per-cell summary tables (and optional figures/reports).

---

## Overview / functionality

A run is driven entirely by a single configuration file (`config.yaml`). You set
which analysis to perform, point the code at a data directory, and it does the
rest. The supported analyses (exactly one is enabled per run via
`analysis_type` in the config) are:

| `analysis_type` flag | What it does |
|---|---|
| `mass` | Buoyant mass of cells from frequency/time data |
| `fl_excl` | Mass/volume from paired frequency/time + fluorescence (PMT) data |
| `density_trap` | Density and volume from density-trapping (two-fluid) measurements |
| `water_content` | Water content from density trapping with D2O |
| `mass_calibration` | Build a mass calibration from bead data |
| `base_freq_density_calibration` | Density calibration from two fluids |
| `dens_trap_base_freq_recal` | Empirical correction of a density baseline calibration (now redundant) |

### Processing stages (mass / analysis path)

1. **Directory parsing** — `helpers/auto_file_select/parse_dir_contents.m` locates
   the raw binary files and calibration JSON in a data folder.
2. **Peak detection** — `final_code/analysis/peak_detection/`
   - `S1_PeakAnalysis_time.m` — segments each data block and finds candidate peaks.
   - `S2_PeaksetFinder.m` — locates the (3-peak, 2nd-mode) peakset apices.
   - `S2_BaselineFinder.m` — finds baseline segments and peak edges.
   - `S2_PeakFitter.m` — polynomial fits for peak height, node deviation, FWHM.
3. **Parameter handling** — `final_code/params/` loads the config, applies
   analysis-type-specific presets (`modify_backend_params.m`), and validates.
4. **Curation** — `final_code/analysis/pk_curation/` auto-rejects low-quality
   peaks (`auto_discard_peaks.m`) and/or opens the manual curation GUI: a
   paginated grid of peaks (configurable N×M via `curation.grid_rows/grid_cols`
   in `config.yaml`) where you click subplots to toggle rejection and navigate
   pages with arrow keys or `n`/`p`. Press `d` or click Done to confirm.
5. **Calibration & summary** — converts peak heights to physical units and writes
   per-cell summary tables.
6. **Visualization / reports** — `final_code/visualization/` produces figures and
   optional PowerPoint reports.

### Entry points

- **`main.m`** — analyze a single data directory. Edit `config.yaml`, then run.
  A folder picker opens to select the data directory.
- **`batch_main.m`** — analyze every immediate subdirectory of a chosen parent
  folder in an unattended loop (forces non-interactive curation).

Both scripts add the needed paths and call `load_run_params()` to read the config.

---

## Repository structure

```
main.m                  Single-directory entry point
batch_main.m            Batch (multi-directory) entry point
config.template.yaml    Tracked template — copy to config.yaml
config.yaml             Your run configuration (gitignored)
final_code/
  params/               Config loading, presets, validation
  analysis/
    peak_detection/     S1/S2 peak detection, baseline, fitting
    pk_curation/        Auto + manual peak curation
    mass_calibration/   Mass calibration
    fl_excl/            Fluorescence-exclusion analysis (PMT)
    density_base_*/     Density baseline calibration / recalibration
  data_dir_formatting/  Raw data directory formatting helpers
  visualization/        Figures and report generation
  scripts/              Utility scripts (e.g. raw data visualization)
helpers/                Shared utilities (file selection, JSON, etc.)
simulation/             SMR signal simulation (independent of the analysis path)
```

---

## Requirements

- **MATLAB R2020a or newer** (the code uses `arguments` blocks, the `string`
  type, and the `yaml` add-on, which requires R2020a+).
- The MathWorks toolboxes and File Exchange add-ons listed below.

### MATLAB add-on / toolbox dependencies

Install MathWorks toolboxes via **Home > Add-Ons > Get Add-Ons**, or check what
you already have with `ver` at the MATLAB prompt.

**Required for all analyses:**

| Dependency | Type | Used for | Example functions |
|---|---|---|---|
| **Signal Processing Toolbox** | MathWorks toolbox | Core peak detection / smoothing | `sgolayfilt`, `sgolay`, `medfilt1` |
| **Curve Fitting Toolbox** | MathWorks toolbox | Baseline / peak smoothing | `smooth` |
| **yaml** (File Exchange ID **106765**) | 3rd-party add-on | Parsing `config.yaml` | `yaml.loadFile` |

> Install the `yaml` add-on from **Add-Ons > Get Add-Ons**, search for "YAML"
> (MathWorks-published, File Exchange ID 106765). Without it, `load_run_params`
> cannot read the config and nothing will run.

**Required only for specific features:**

| Dependency | Type | Needed when |
|---|---|---|
| **Statistics and Machine Learning Toolbox** | MathWorks toolbox | Fluorescence-exclusion analysis (`fl_excl`) and Coulter calibration — uses `prctile`, `ksdensity` |
| **MATLAB Report Generator** | MathWorks toolbox | Generating PowerPoint/PDF reports (`final_code/visualization/reports/`, `fl_excl` reports) — uses `mlreportgen.*` |
| **DSP System Toolbox** | MathWorks toolbox | Running the `simulation/` signal generators only — uses `dsp.ColoredNoise` (not needed for analyzing real data) |

---

## Setup

1. Clone the repository.
2. Install the dependencies listed above (in particular the **yaml** add-on).
3. Create your config from the template:
   ```
   cp config.template.yaml config.yaml
   ```
   `config.yaml` is gitignored; the template is tracked.
4. Edit `config.yaml` for your run (see below).

---

## Configuration (`config.yaml`)

All run settings live in `config.yaml`. Key sections:

- **`analysis_type`** — set exactly one analysis to `true`.
- **`analysis_params`** — `analysismode` (`true` = rapid, runs through all peaks;
  `false` = stop at each peak), progress display, verbosity.
- **`prefs`** — manual curation, loading previous curation, multi-size bead mode.
- **`curation`** — auto-rejection thresholds (peak/node imbalance, node deviation).
- **`bl_select`** — baseline-selection and peak-detection parameters. When
  `use_presets: true`, these are **overridden** per analysis type by
  `final_code/params/modify_backend_params.m`.
- **`fl_excl`**, **`density_trap`**, **`mass_cal`**, **`vis`**, **`backend`** —
  feature-specific settings.

> Note: `backend.*` flags that change algorithm behavior (e.g.
> `baseline_fit_type`, `extended_bl_detect`, `adjusted_edge_indices`,
> `fixed_peakset_thresh`) are set in `modify_backend_params.m` based on the
> selected analysis type, not directly in `config.yaml`.

---

## Usage

### Analyze one directory

1. Set the desired `analysis_type` in `config.yaml`.
2. Run `main.m`.
3. Select the data directory in the folder picker; answer any prompts (e.g.
   whether peaks are inverted).

### Batch-analyze many directories

1. Configure `config.yaml` as above.
2. Run `batch_main.m`.
3. Select a parent directory; every immediate subdirectory is analyzed in turn.
   Failures are caught and reported in a summary at the end.

### Expected raw data format

A data directory is expected to contain big-endian binary files matched by name:

- `<timestamp>_frequencies` — `float64`, 8 bytes/sample (resonant frequency)
- `<timestamp>_time` — `float64`, 8 bytes/sample
- `<timestamp>_valvestates` — `uint8`, 1 byte/sample (optional)
- `<…>_mass_calibration.json` — calibration parameters (for mass analysis)

All streams are indexed by the same sample number. Utility scripts under
`final_code/scripts/data_visualization/` (e.g. `vis_freq_data_whole.m`) can plot
raw frequency data for inspection.

---

## Outputs

Depending on the analysis type, the pipeline writes per-cell summary tables
(mass, volume, density, node deviation, etc.) into a results subdirectory of the
input folder, plus optional figures and PowerPoint/PDF reports.

---

## Buoyant-mass gating GUI (`gate_mass_results.m`)

A standalone, interactive GUI (repo root) for **post-analysis gating** of buoyant
mass data across a whole experiment — a tool to keep only the cell populations you
want, one gated CSV per sample. Requires no extra toolboxes.

### Input layout

Point it at a **superdirectory** whose immediate subfolders are individual samples,
each containing a mass-results folder produced by the analysis pipeline:

```
<superdir>/
  <sample_1>/<yyyyMMdd.HHmmss>_mass_results/<...>.csv
  <sample_2>/<yyyyMMdd.HHmmss>_mass_results/<...>.csv
  ...
```

The script auto-discovers each sample's mass-results CSV (choosing the **most
recent** `_mass_results` folder if several exist, and skipping `curation_index`
and macOS `._*` files). Subfolders with no mass-results folder are skipped.

### How to run

Run `gate_mass_results` (no arguments). By default a **folder picker** opens to
choose the superdirectory. To skip the picker, paste a path into the `superdir`
CONFIG line near the top of the script. Works cross-platform (Windows/macOS) and
adapts to any window/monitor size.

### Workflow

1. **Selection window** — a multi-select list of samples.
   - **Select all** selects every sample (to gate them all together).
   - **Set gate** opens the gating window on the selected samples.
   - **Browse** opens a read-only overlay viewer (sidebar checkboxes show/hide each
     sample across all plots) so you can inspect the currently ungated samples.
   - **Undo** rolls back the most recent gating action.
   - **Done** writes the gated CSVs and closes.
2. **Gating window** — the selected samples are overlaid as histograms (one color
   each) across four plots:
   - Buoyant mass (`mass_pg`)
   - Normalized baseline — `avg_baseline` divided, per sample, by the mean baseline
     over the **first 10%** of that sample's run (by `peak_time_m`); the x-axis is
     labeled as a fraction of the first-10% mean.
   - Baseline slope (`bl_slope`)
   - Average node deviation (`node_dev_mean`)

   Every plot is gated the same way: click its **Gate: …** button, then click once
   to set the lower cutoff (red dashed line) and again to set the upper cutoff (blue
   dashed line). A green band marks the accepted range; click the button again to
   redraw. Gate any subset of the four plots (gates are optional per plot) — the
   accepted set is the logical **AND** across the plots that have a cutoff, and the
   status bar shows the running accepted count. **Apply** filters each selected
   sample by the current gates; **Reset gates** clears them; **Back** cancels.

   Each histogram has **x-limit boxes** (`x min` / `x max`, blank = auto) beneath it
   that zoom and re-bin that plot within the given range — useful for seeing the
   distribution shape when data span a large range. X-limits only affect the view;
   gates always apply to the true data values.

### Output

For each gated sample, a folder `<yyyyMMdd.HHmmss>_gated_mass_results/` is created
**inside that sample's subdirectory**, containing a CSV named
`<sample_name>_bm_gated.csv` with the gated subset of rows (all columns preserved).
All samples gated in the same session share the same timestamp folder name.
Ungated samples produce no output.
