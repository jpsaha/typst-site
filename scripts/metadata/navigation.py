def sort_lectures(lectures):
    """Sort lectures by lecture number."""

    lectures.sort(
        key=lambda lecture: (
            lecture.get("number") is None,
            lecture.get("number")
            if lecture.get("number") is not None
            else 10**9,
            lecture.get("file"),
        )
    )


def add_navigation(lectures):
    """
    Add previous/next links to numbered lectures.

    Non-numbered pages are not included.
    """

    numbered = [
        lecture
        for lecture in lectures
        if lecture.get("number") is not None
    ]

    for index, lecture in enumerate(numbered):

        # Previous
        if index > 0:

            previous = numbered[index - 1]

            lecture["previous"] = {
                "title": previous["title"],
                "html": (
                    previous["file"]
                    + ".html"
                ),
            }

        else:

            lecture["previous"] = None

        # Next
        if index < len(numbered) - 1:

            next_lecture = numbered[index + 1]

            lecture["next"] = {
                "title": next_lecture["title"],
                "html": (
                    next_lecture["file"]
                    + ".html"
                ),
            }

        else:

            lecture["next"] = None


def add_page_navigation(pages):
    """
    Pages currently do not participate
    in lecture navigation.
    """

    for page in pages:

        page["previous"] = None
        page["next"] = None
