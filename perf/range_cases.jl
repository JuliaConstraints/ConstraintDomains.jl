module RangeCases
import ConstraintDomains as CD
import ConstraintCommons as CC
current(state) = CD.domain_size(state.domain)
original(state) = invoke(CC.δ_extrema, Tuple{Any}, state.values)
function span(parameters)
    n = Int(get(parameters, "n", 1000))
    values = 1:n
    expected = isempty(values) ? Inf : n - 1
    operation = get(parameters, "method", "current") == "original" ? original : current
    (; prepare=() -> (; values, domain=CD.domain(values)), operation,
        verify=(state, result) -> result == expected && CD.get_domain(state.domain) == values)
end
end
