// Public API
#import "utils.typ": is-html
#import "counters.typ": (
  math-counter,
  math-number,
  reset-counters,
  lecture-number,
)
#import "render.typ": block-container, page-header, setup-document, lecture-info
#import "blocks.typ": theorem, definition, exercise, note, warning, example, remark, history, proof, corollary, lemma, proposition, claim
#import "nav.typ": html-nav-header, previous-next
#import "colors.typ"
#import "code.typ": (
  python,
  sage,
  lean,
  julia,
  asy,
)