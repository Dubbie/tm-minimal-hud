namespace JsonUtil {
    bool HasField(
        const Json::Value &in data,
        const string &in name,
        Json::Type expectedType
    ) {
        return data.GetType() == Json::Type::Object
            && data.HasKey(name)
            && data[name].GetType() == expectedType;
    }
}