class BaseGenerator:

    def generate(self):
        raise NotImplementedError()

    def validate(self):
        raise NotImplementedError()

    def save(self):
        raise NotImplementedError()