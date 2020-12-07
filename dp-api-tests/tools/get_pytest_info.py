import os
import importlib
import inspect


class PyTestTool(object):

    @classmethod
    def _get_all_pytest_files(cls):
        root_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        test_root_dir = os.path.join(root_path, 'tests')

        pytest_files = []
        for dir_path, _, files in os.walk(test_root_dir):
            for file in files:
                if file.startswith('test_') and file.endswith('.py'):
                    pytest_files.append(os.path.join(dir_path, file))
        return pytest_files

    @classmethod
    def _load_pytest_cases_metadata(cls, file_path):
        file_name = os.path.basename(file_path)
        full_name = os.path.splitext(file_name)[0]
        source = importlib.machinery.SourceFileLoader(full_name, file_path)
        imported = source.load_module(full_name)

        ret_dict = {}
        for _, mod in vars(imported).items():
            if inspect.isclass(mod) and mod.__name__.startswith('Test'):
                fns = []
                for _, attr in vars(mod).items():
                    if callable(attr) and attr.__name__.startswith('test_') and hasattr(attr, 'meta_data'):
                        fns.append("fn_name=%s,%s" %
                                   (attr.__name__, getattr(attr, 'meta_data')))
                if len(fns) > 0:
                    ret_dict[mod.__name__] = fns
        return ret_dict

    @classmethod
    def print_all_pytest_cases_metadata(cls):
        for file_path in cls._get_all_pytest_files():
            metadata_dict = cls._load_pytest_cases_metadata(file_path)
            if len(metadata_dict) == 0:
                continue
            print(os.path.basename(file_path))
            print(metadata_dict)
            print()
