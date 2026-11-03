class ReferenceCache:

    data = {}

    @classmethod
    def set(cls, table_name, dataframe):

        cls.data[table_name] = dataframe

    @classmethod
    def get(cls, table_name):

        return cls.data.get(table_name)

    @classmethod
    def clear(cls):

        cls.data.clear()