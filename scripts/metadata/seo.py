#!/usr/bin/env python3

"""
SEO helpers for the Typst course website.

Provides:
    - HTML escaping
    - canonical URLs
    - meta tags
    - OpenGraph tags
    - Twitter Card tags
"""

from html import escape
from urllib.parse import urljoin

from scripts.config import (
    SITE_URL,
    SITE_TITLE,
    SITE_DESCRIPTION,
    SITE_AUTHOR,
    SITE_OG_IMAGE,
    SITE_LANGUAGE,
)


# ============================================================
# URL
# ============================================================

def absolute_url(path):
    """Convert a site-relative path into an absolute URL."""

    return urljoin(
        SITE_URL.rstrip("/") + "/",
        path.lstrip("/"),
    )


# ============================================================
# HTML escaping
# ============================================================

def html_escape(value):
    """Escape a value for safe insertion into HTML."""

    return escape(
        str(value),
        quote=True,
    )


# ============================================================
# SEO metadata
# ============================================================

def seo_head(
    *,
    title,
    description=None,
    path="/",
    og_type="website",
    image=None,
):
    """
    Generate SEO/OpenGraph/Twitter metadata.

    Parameters
    ----------
    title:
        Page title.

    description:
        Meta description.

    path:
        Site-relative URL.

    og_type:
        OpenGraph type, usually 'website' or 'article'.

    image:
        Site-relative image URL.
    """

    if description is None:
        description = SITE_DESCRIPTION

    canonical = absolute_url(path)

    if image is None:
        image = SITE_OG_IMAGE

    image_url = absolute_url(image)

    title = html_escape(title)
    description = html_escape(description)
    canonical = html_escape(canonical)
    image_url = html_escape(image_url)
    site_title = html_escape(SITE_TITLE)

    lines = [
        f'    <title>{title}</title>',
        f'    <meta name="description" content="{description}">',
        f'    <link rel="canonical" href="{canonical}">',
        f'    <meta name="author" content="{html_escape(SITE_AUTHOR)}">'
        if SITE_AUTHOR
        else "",
        "",
        f'    <meta property="og:type" content="{og_type}">',
        f'    <meta property="og:title" content="{title}">',
        f'    <meta property="og:description" content="{description}">',
        f'    <meta property="og:url" content="{canonical}">',
        f'    <meta property="og:site_name" content="{site_title}">',
        f'    <meta property="og:image" content="{image_url}">',
        "",
        '    <meta name="twitter:card" '
        'content="summary_large_image">',
        f'    <meta name="twitter:title" content="{title}">',
        f'    <meta name="twitter:description" '
        f'content="{description}">',
        f'    <meta name="twitter:image" content="{image_url}">',
        "",
        f'    <meta name="language" content="{SITE_LANGUAGE}">',
    ]

    return "\n".join(
        line
        for line in lines
        if line != ""
    )