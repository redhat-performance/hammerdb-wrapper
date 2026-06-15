# HammerDB (Database Performance) Benchmark Wrapper

## Description

This wrapper facilitates the automated execution of the HammerDB database benchmark. HammerDB is the leading benchmarking and load testing software for the world's most popular databases. It implements TPC-C style OLTP workloads to measure database transaction throughput in Transactions Per Minute (TPM).

The wrapper provides:
- Automated HammerDB installation and execution.
- Support for three database engines: MariaDB, PostgreSQL, and Microsoft SQL Server.
- Automatic database installation, configuration, and schema build.
- Automatic LVM volume and filesystem creation for database storage.
- Optional separate log disk support for database write-ahead logs.
- Configurable user (connection) count scaling.
- Configurable warehouse count for database sizing.
- Support for local and remote (multi-host) database deployments.
- Automatic memory-based buffer pool sizing.
- Result collection, processing, and verification.
- CSV and JSON output formats.
- System configuration metadata capture.
- Integration with test_tools framework.
- Optional Performance Co-Pilot (PCP) integration.

For more information see: https://github.com/TPC-Council/HammerDB

## Command-Line Options

```
HammerDB Options:
  --disks <value>: Comma-separated list of disk devices to use for database storage.
      Special value "grab_disks" auto-detects all unmounted disks.
      Required.
  --filesys <type>: Filesystem type to create on the disk devices. Default: xfs.
  --log_disks <value>: Comma-separated list of disk devices for database log storage.
      Creates a separate LVM volume and filesystem mounted at /perf2.
      Optional; if not specified, logs are stored on the main data filesystem.
  --sub_test <type>: Database engine to test. Required.
      Supported values: mariadb, mssql, postgres.
  --users <value>: Comma-separated list of user (connection) counts to test.
      Default: 10,20,40.
  --warehouses <value>: Number of TPC-C warehouses to build in the database.
      Default: 1000 for MariaDB, 500 for PostgreSQL and MSSQL.
  --usage: Display this usage message.

General test_tools options:
  --debug: Enable bash -x debug output for wrapper troubleshooting.
  --home_parent <value>: Parent home directory. If not set, defaults to current working directory.
  --host_config <value>: Host configuration name, defaults to current hostname.
  --iterations <value>: Number of times to run the test, defaults to 1.
  --json_skip: Skip JSON conversion of test CSV results.
  --no_pkg_install: Do not install any packages (system or pip). Useful for pre-provisioned systems.
  --no_system_packages: Do not install system packages via the package manager. Pip packages are still installed.
  --no_pip_packages: Do not install Python pip packages. System packages are still installed.
  --run_label <value>: Label to associate with the run. No default.
  --run_user: User that is actually running the test on the test system. Defaults to current user.
  --sys_type: Type of system working with (aws, azure, hostname). Defaults to hostname.
  --sysname: Name of the system running, used in determining config files. Defaults to hostname.
  --test_tools_release <tag>: Version tag of test_tools-wrappers to check out and use.
  --tuned_setting: Used in naming the results directory. For RHEL, defaults to current active tuned profile.
      For non-RHEL systems, defaults to 'none'. If set to a profile name, activates that tuned profile.
  --use_pcp: Enable Performance Co-Pilot monitoring during test execution.
  --verify_skip: Skip result verification against the Pydantic schema.
  --tools_git <value>: Git repo to retrieve the required tools from.
      Default: https://github.com/redhat-performance/test_tools-wrappers
  --usage: Display this usage message.
```

## What the Script Does

The wrapper consists of two scripts: `hammerdb` (entry point) and `run_hammerdb` (core test runner). Together they perform the following workflow:

1. **Environment Setup**:
   - Disables SELinux (`setenforce 0`) for the duration of the test.
   - Clones the test_tools-wrappers repository if not present (default: ~/test_tools).
   - Sources error codes and general setup utilities.
   - Gathers hardware information via `gather_data`.
   - Unsets the `DISPLAY` variable (HammerDB CLI mode requires no display).

2. **Package Installation**:
   - Installs base dependencies via package_tool using `hammerdb.json` (lvm2, sysstat, bc, git, zip, unzip).
   - Installs database-specific packages based on `--sub_test`:
     - **MariaDB**: mariadb, mariadb-common, mariadb-errmsg, mariadb-server, mariadb-server-utils (from `hammerdb_mariadb.json`).
     - **PostgreSQL**: postgresql, postgresql-contrib, postgresql-server, glibc-langpack-en, libpq (from `hammerdb_postgres.json`).
     - **MSSQL**: installed from Microsoft repositories via the `install-script`.
   - Package definitions are currently defined for RHEL only.

3. **Storage Setup**:
   - Creates an LVM volume group and logical volume from the specified disks.
   - Creates a filesystem (default: XFS) on the logical volume.
   - Mounts the filesystem at `/perf1` for database data storage.
   - Optionally creates a separate LVM volume and filesystem at `/perf2` for database logs when `--log_disks` is specified.
   - Supports `grab_disks` for auto-detecting unmounted disks.

4. **Tuned Profile**:
   - If `--tuned_setting` is specified and not "none", records the current active profile, then switches to the requested profile.
   - Restores the original profile after the test completes.

5. **HammerDB Installation**:
   - The `install-script` extracts the HammerDB kit from `~/uploads/hammerdb-tpcc.tar`.
   - Installs HammerDB 3.2 to `/usr/local/HammerDB` using the non-interactive installer.
   - Copies database-specific TCL scripts (build and run scripts) from the extracted kit.
   - For remote deployments: copies `install-script` to each remote host via SCP and executes it remotely.

6. **Database Installation and Configuration**:
   - **MariaDB**:
     - Installs MariaDB packages.
     - Configures data directory on `/perf1/mysql/data` and log directory.
     - Auto-sizes `innodb_buffer_pool_size` to half of system memory (capped at 64000 MiB).
     - Sets root password and restarts the service.
   - **PostgreSQL**:
     - Installs PostgreSQL packages.
     - Runs `postgresql-setup initdb` with data on `/perf1/postgres_data`.
     - Moves `pg_wal` to the log filesystem for write-ahead log separation.
     - Auto-sizes `shared_buffers` to half of system memory (capped at 64000 MiB).
     - Sets postgres user password and restarts the service.
   - **MSSQL**:
     - Installs MSSQL Server from Microsoft repositories.
     - Configures data directory on `/perf1/mssql_data`.
     - Runs initial setup with evaluation license.
     - Creates the database and configures temp mount points.

7. **Schema Build**:
   - Drops any existing `tpcc` database.
   - Runs the HammerDB build TCL script (`build_<db>.tcl`) to create and populate the TPC-C schema.
   - The schema is sized according to the warehouse count.
   - For remote hosts: runs the build script on each host in parallel via SSH, then waits for all to complete.

8. **Test Execution**:
   - Iterates over the configured user counts (default: 10, 20, 40).
   - For each user count:
     - Copies and modifies the run TCL script (`runtest_<db>.tcl`) to set the user count and host.
     - Executes `hammerdbcli auto <script>` to run the benchmark.
     - Captures start and end timestamps.
   - For remote hosts: launches tests on each host in parallel via SSH, waits for completion, then sleeps 120 seconds for stabilization.
   - Optionally collects PCP data per user count.

9. **Result Processing**:
   - Extracts "Active Virtual Users configured" (connection count) and TPM (Transactions Per Minute) from HammerDB output.
   - Generates CSV with connection count and TPM per user count.
   - Creates JSON output for verification.

10. **Verification**:
    - Validates results against the Pydantic schema (`results_schema.py`).
    - Ensures all required fields are present and valid (connection > 0, TPM > 0, timestamps).
    - Uses `csv_to_json` and `verify_results` from test_tools.

11. **Output and Cleanup**:
    - Creates a tar archive of results: `results_hammerdb_<db>_<tuned>.tar`.
    - Saves raw HammerDB output files, processed CSV/JSON, and test status.
    - Optionally saves PCP performance data.
    - Archives results to configured storage location via `save_results`.
    - Moves HammerDB installation to `/usr/local/<db>` for preservation.
    - Restores the original tuned profile if changed.
    - Re-enables SELinux (`setenforce 1`).
    - Deletes the LVM volume group and unmounts `/perf1`.

## Dependencies

**Location of underlying workload**: HammerDB is a licensed/free benchmark. You must upload the HammerDB TPC-C kit archive (`hammerdb-tpcc.tar`) to `~/uploads`. This archive contains the HammerDB 3.2 installer and database-specific TCL scripts (build and run scripts for MariaDB, PostgreSQL, and MSSQL).

**Base packages required** (RHEL only): lvm2, sysstat, bc, git, unzip, zip

**Database-specific packages**:
- **MariaDB** (RHEL): mariadb, mariadb-common, mariadb-errmsg, mariadb-server, mariadb-server-utils
- **PostgreSQL** (RHEL): postgresql, postgresql-contrib, postgresql-server, glibc-langpack-en, libpq
- **MSSQL**: Installed from Microsoft repositories (mssql-server, mssql-tools, unixODBC-devel)

**Storage requirements**: At least one unused disk device (or unmounted disk) is required for database storage. A second disk is recommended for database log separation (via `--log_disks`).

To run:
```bash
# Upload the HammerDB TPC-C kit first
cp hammerdb-tpcc.tar ~/uploads/

# Clone and run
git clone https://github.com/redhat-performance/hammerdb-wrapper
cd hammerdb-wrapper/hammerdb
./hammerdb --sub_test mariadb --disks /dev/sdb
```

The script will create the filesystem, install the database, build the schema, and execute the benchmark.

## The HammerDB Benchmark

HammerDB implements a TPC-C style Online Transaction Processing (OLTP) workload. TPC-C simulates a complete order-entry environment for a wholesale supplier, exercising a mix of read-write and read-only transactions.

### Key HammerDB Parameters

1. **Warehouses**: The primary database sizing parameter. Each warehouse contains approximately 100 MiB of data. More warehouses mean a larger database, which exercises more I/O and memory. Defaults: 1000 for MariaDB, 500 for PostgreSQL and MSSQL.

2. **Virtual Users (Connections)**: The number of concurrent database connections. More users means higher concurrency and contention. The wrapper scales through a configurable list of user counts (default: 10, 20, 40).

3. **Performance Metric**: HammerDB reports performance in **TPM** (Transactions Per Minute). Higher values indicate better database throughput. TPM includes all five TPC-C transaction types: New Order, Payment, Order Status, Delivery, and Stock Level.

### Supported Database Engines

- **MariaDB**: Open-source relational database, MySQL-compatible. Uses InnoDB storage engine with `innodb_buffer_pool_size` auto-sized to half of system memory (capped at 64 GiB).
- **PostgreSQL**: Open-source object-relational database. Uses `shared_buffers` auto-sized to half of system memory (capped at 64 GiB). Write-ahead logs are separated to a dedicated filesystem when `--log_disks` is specified.
- **Microsoft SQL Server (MSSQL)**: Commercial relational database (evaluation license). Requires Microsoft's RHEL repository for installation.

## Output Files

The results directory (archived as `results_hammerdb_<db>_<tuned>.tar`) contains:

- **results_hammerdb_\<db\>.csv**: CSV file with connection counts and TPM values.
- **results_hammer.json**: JSON output validated against the Pydantic schema.
- **test_\<db\>_\*.out**: Raw HammerDB output files with detailed benchmark results per user count.
- **build_\<db\>_\*.out**: Database schema build output.
- **test_results_report**: File indicating test status ("Ran" or "Failed").
- **hammerdb.out**: Full script execution log.
- **meta_data\*.yml**: System metadata (CPU info, memory, NUMA topology, kernel version).
- **PCP data** (if --use_pcp option used): Performance Co-Pilot monitoring data.

### Results Schema

Results are validated against the following Pydantic schema (`results_schema.py`):

| Field | Type | Constraint |
|-------|------|------------|
| connection | int | > 0 |
| TPM | int | > 0 |
| Start_Date | datetime | required |
| End_Date | datetime | required |

## Examples

### MariaDB test with a single disk
```bash
./hammerdb --sub_test mariadb --disks /dev/sdb
```
This runs with:
- MariaDB database engine
- Default 1000 warehouses
- User counts 10, 20, 40
- XFS filesystem on /dev/sdb

### PostgreSQL test
```bash
./hammerdb --sub_test postgres --disks /dev/sdb
```
Runs the PostgreSQL benchmark with default settings (500 warehouses).

### MSSQL test
```bash
./hammerdb --sub_test mssql --disks /dev/sdb
```
Runs the Microsoft SQL Server benchmark with default settings (500 warehouses).

### Custom user counts
```bash
./hammerdb --sub_test mariadb --disks /dev/sdb --users 10,20,40,80,100
```
Tests with five different user (connection) counts.

### Custom warehouse count
```bash
./hammerdb --sub_test postgres --disks /dev/sdb --warehouses 200
```
Builds a 200-warehouse database for a smaller/faster test.

### Separate log disk
```bash
./hammerdb --sub_test postgres --disks /dev/sdb --log_disks /dev/sdc
```
Uses `/dev/sdb` for database data and `/dev/sdc` for write-ahead logs, providing I/O separation for better performance.

### Auto-detect disks
```bash
./hammerdb --sub_test mariadb --disks grab_disks
```
Automatically discovers all unmounted disk devices and uses them for the database storage LVM volume.

### Custom filesystem type
```bash
./hammerdb --sub_test mariadb --disks /dev/sdb --filesys ext4
```
Creates an ext4 filesystem instead of the default XFS.

### Run with PCP monitoring
```bash
./hammerdb --sub_test mariadb --disks /dev/sdb --use_pcp
```
Collects Performance Co-Pilot data during the run.

### Combination example
```bash
./hammerdb --sub_test postgres --disks /dev/sdb --log_disks /dev/sdc \
    --warehouses 500 --users 10,20,40,80 --use_pcp \
    --tuned_setting throughput-performance
```
Runs PostgreSQL with 500 warehouses, four user counts, separate log disk, PCP monitoring, and the `throughput-performance` tuned profile.

## How Database Sizing Works

### Buffer Pool / Shared Buffers
The wrapper automatically sizes the database memory allocation based on system RAM:

1. Detects total system memory from `/proc/meminfo`.
2. Calculates buffer size as half of total memory:
   ```
   buffer_size = total_memory_MiB / 2
   ```
3. Caps the buffer size at 64000 MiB (approximately 64 GiB).
4. Applies to:
   - **MariaDB**: `innodb_buffer_pool_size` in `my.cnf`
   - **PostgreSQL**: `shared_buffers` in `postgresql.conf`

### Warehouse Sizing
- Each TPC-C warehouse contains approximately 100 MiB of initial data.
- Default warehouses: 1000 for MariaDB, 500 for PostgreSQL and MSSQL.
- Larger warehouse counts increase the working dataset size, making it more likely to exceed memory and exercise disk I/O.
- Can be overridden with `--warehouses`.

### Storage Layout
```
/perf1/                    (main data filesystem, LVM on --disks)
  mysql/data/              (MariaDB data directory)
  postgres_data/           (PostgreSQL data directory)
  mssql_data/              (MSSQL data directory)

/perf2/                    (optional log filesystem, LVM on --log_disks)
  mysql/log/               (MariaDB InnoDB logs)
  postgres_log/pg_wal/     (PostgreSQL write-ahead logs)
```

## Return Codes

The script uses standardized error codes from test_tools error_codes:
- **0 (E_SUCCESS)**: Success
- **101**: Git clone failure (test_tools repository)
- **E_GENERAL**: General execution errors (LVM creation failures, filesystem creation failures, disk grab failures, database installation failures).
- **E_PARSE_ARGS**: Argument parsing failure
- **E_USAGE**: Invalid usage/arguments or missing required `--sub_test` parameter

A non-zero return code from `verify_results` indicates that the output data did not pass schema validation.

## Notes

### Licensed/Kit Requirements
The HammerDB TPC-C kit (`hammerdb-tpcc.tar`) must be uploaded to `~/uploads` before running. This archive contains:
- HammerDB 3.2 Linux x86-64 installer.
- Database-specific TCL scripts for schema build and test execution.
- Database-specific configuration files (e.g., `my.cnf` for MariaDB, `postgresql.conf` for PostgreSQL).

### Platform Support
- **Operating System**: RHEL only. All package definition files (`hammerdb.json`, `hammerdb_mariadb.json`, `hammerdb_postgres.json`) only define RHEL dependencies.
- **Architecture**: x86_64 (HammerDB 3.2 installer is x86-64 only).

### SELinux
- The wrapper disables SELinux (`setenforce 0`) at the start and re-enables it (`setenforce 1`) at completion.
- This is required because database processes need unrestricted access to the custom data directories on `/perf1` and `/perf2`.

### Storage Requirements
- At least one unused disk device is required (`--disks` is mandatory).
- The wrapper creates LVM volumes and filesystems, which is destructive to any existing data on the specified disks.
- `grab_disks` auto-detects unmounted disks but does not recognize devices with unmounted filesystems — those will be treated as available.
- Using `--log_disks` for write-ahead log separation is recommended for production benchmarking to avoid I/O contention between data and log writes.

### Remote (Multi-Host) Deployments
The `run_hammerdb` script supports running against remote database hosts via the `-H` flag (used internally by the wrapper). When remote hosts are specified:
- The `install-script` is copied to each host via SCP and executed remotely.
- Build and run TCL scripts are modified and executed on each host via SSH.
- All remote builds and tests run in parallel.
- After test completion, a 120-second stabilization period is observed before the next user count.
- Passwordless SSH as root must be configured to all remote hosts.

### Performance Tips
- Use separate disks for data and logs (`--log_disks`) to reduce I/O contention.
- Ensure the database buffer pool/shared buffers fit in memory — the wrapper auto-sizes to half of RAM.
- Use the `throughput-performance` or `latency-performance` tuned profiles for database workloads.
- Larger warehouse counts stress I/O more; smaller counts keep the dataset in memory.
- Run multiple user counts to find the saturation point where TPM plateaus.

### Troubleshooting
- If LVM creation fails, verify the specified disks are not in use or mounted.
- If the database fails to start, check the build output files (`build_<db>_*.out`) for errors.
- If TPM is 0 or very low, verify the database schema was built successfully and the database service is running.
- If HammerDB is not found, verify `hammerdb-tpcc.tar` is present in `~/uploads`.
- If package installation fails, verify the system has access to the required repositories (especially Microsoft's repo for MSSQL).
- Use `--use_pcp` to collect detailed performance counters for analysis.
- The full script execution log is saved to `hammerdb.out` in the results directory.
