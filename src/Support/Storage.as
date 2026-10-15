namespace Storage {
    enum LoadResult {
        Missing,
        Failed,
        Loaded
    }

    string Backup(const string &in baseName) {
        // create backup file datetimed e.g. <baseName>.broken-<dateTime>.json
        string originalPath = IO::FromStorageFolder(baseName + ".json");
        string dateTime = Time::FormatString("%Y-%m-%d_%H-%M-%S", Time::Stamp);
        string backupName = baseName + ".broken-" + dateTime + ".json";
        string backupPath = IO::FromStorageFolder(backupName);

        IO::Move(originalPath, backupPath);

        return backupName;
    }
}