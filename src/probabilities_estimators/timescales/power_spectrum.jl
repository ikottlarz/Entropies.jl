export PowerSpectrum
import FFTW

"""
    PowerSpectrum() <: ProbabilitiesEstimator

Calculate the power spectrum of a timeseries (amplitude square of its Fourier transform),
and return the spectrum normalized to sum = 1 as probabilities.
The Shannon entropy of these probabilities is typically referred in the literature as
_spectral entropy_, e.g. [^Llanos2016],[^Tian2017].

The closer the spectrum is to flat, i.e., white noise, the higher the entropy. However,
you can't compare entropies of timeseries with different length, because the binning
in spectral space depends on the length of the input.

The events in [`probabilities_and_events`](@ref) are just the frequencies in Fourier
space. They should be multiplied with the sampling rate of the signal, which is assumed
to be `1`.

[^Llanos2016]:
    Llanos et al., _Power spectral entropy as an information-theoretic correlate of manner
    of articulation in American English_, [The Journal of the Acoustical Society of America
    141, EL127 (2017)](https://doi.org/10.1121/1.4976109)

[^Tian2017]:
    Tian et al, _Spectral Entropy Can Predict Changes of Working Memory Performance Reduced
    by Short-Time Training in the Delayed-Match-to-Sample Task_,
    [Front. Hum. Neurosci.](https://doi.org/10.3389/fnhum.2017.00437)
"""
struct PowerSpectrum <: ProbabilitiesEstimator end

function probabilities(x::Array_or_Dataset, ::PowerSpectrum)
    @assert x isa AbstractVector{<:Real} "`PowerSpectrum` only works for timeseries input!"
    f = FFTW.rfft(x)
    Probabilities(abs2.(f))
end

function probabilities_and_events(x::Array_or_Dataset, est::PowerSpectrum)
    probs = probabilities(x, est)
    events = FFTW.rfftfreq(length(x))
    return probs, events
end

function alphabet_length(x::Array_or_Dataset, ::PowerSpectrum)
    n = length(x)
    # From the docstring of `AbstractFFTs.rfftfreq`:
    iseven(n) ? length(0:(n÷2)) : length(0:((n-1)÷2))
end
