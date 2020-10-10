import os
from pathlib import Path
import shutil


from Cython.Build import build_ext
from Cython.Build import cythonize
from Cython.Compiler import Options
import numpy as np
from setuptools import Distribution
from setuptools import Extension


PROFILING_MODE = bool(os.getenv("PROFILING_MODE", "False"))
PROFILING_MODE = True
print(f"{PROFILING_MODE=}")

# ------------------------------------------------------------------------------
# Cython (edit here only)
# ------------------------------------------------------------------------------
# https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html

# Cython build options
Options.annotate = True  # Create annotated html files for each .pyx
Options.docstrings = True  # Include docstrings in modules
Options.embed_pos_in_docstring = True  # Embed docstrings in extensions
Options.fast_fail = True  # Abort compilation on first error
Options.warning_errors = True  # Treat compiler warnings as errors
LINE_TRACING = PROFILING_MODE  # Enable line tracing for code coverage

# Cython compiler directives
CYTHON_COMPILER_DIRECTIVES = {
    "language_level": 3,  # Python 3 default (can remove soon)
    "cdivision": True,  # If division is as per C with no check for zero (35% speed up)
    "embedsignature": True,  # If docstrings should be embedded into C signatures
    "emit_code_comments": True,  # If comments should be emitted to generated C code
    "linetrace": LINE_TRACING,  # See above
}

extensions = [
    Extension(
        str(pyx.relative_to(".")).replace(os.path.sep, ".")[:-4],
        [str(pyx)],
        include_dirs=[".", np.get_include()],
        library_dirs=[".", np.get_include()],
    )
    for pyx in Path("nautilus_trader").rglob("*.pyx")
]


def build(setup_kwargs):
    """Based upon: https://github.com/sdispater/pendulum/blob/master/build.py"""
    distribution = Distribution(
        dict(
            name="nautilus_trader",
            cmdclass=dict(build_ext=build_ext),
            ext_modules=cythonize(
                module_list=extensions,
                compiler_directives=CYTHON_COMPILER_DIRECTIVES,
                nthreads=os.cpu_count(),
                build_dir="build",
            ),
            zip_safe=False,
        )
    )
    distribution.package_dir = "nautilus_trader"

    cmd = build_ext(distribution)
    cmd.ensure_finalized()
    cmd.run()

    # Copy built extensions back to the project
    for output in cmd.get_outputs():
        relative_extension = os.path.relpath(output, cmd.build_lib)
        if not os.path.exists(output):
            continue

        # Copy the file and set permissions
        shutil.copyfile(output, relative_extension)
        mode = os.stat(relative_extension).st_mode
        mode |= (mode & 0o444) >> 2
        os.chmod(relative_extension, mode)

    return setup_kwargs


if __name__ == "__main__":
    print("")
    # Work around a Cython problem in Python 3.8.x on MacOS
    # https://github.com/cython/cython/issues/3262
    if os.uname().sysname == "Darwin":
        print("MacOS: Setting multiprocessing method to 'fork'.")
        import multiprocessing

        multiprocessing.set_start_method("fork", force=True)

    print("Starting build")
    build({})
