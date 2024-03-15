# Patch api stuff to correct anything that cannot weight for the
# next release
# This file should be cleaned up after a release when the patches
# are not required
from pathlib import Path


def set_release_date():
    """
    Use this method to insert a release date if it was forgotten
    """
    # Forget to set the release date
    file = Path("changelog.qmd")
    contents = (
        file
        .read_text()
        .replace(
            "## v0.13.2\n(not-yet-released)", "## v0.13.2\n(2024-03-14)"
        )
    )
    file.write_text(contents)


if __name__ == "__main__":
    set_release_date()
