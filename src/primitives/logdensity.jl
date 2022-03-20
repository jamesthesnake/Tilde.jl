
export logdensityof

using NestedTuples: lazymerge
import MeasureTheory

using Accessors

@inline function logdensityof(cm::AbstractConditionalModel, pars::NamedTuple)
    # TODO: Check insupport
    dynamic(unsafe_logdensityof(cm, pars))
end

@inline function MeasureBase.unsafe_logdensityof(cm::AbstractConditionalModel, pars::NamedTuple; cfg=NamedTuple(), ctx=NamedTuple())
    cfg = merge(cfg, (pars=pars,))
    ctx = merge(ctx, (ℓ = partialstatic(0.0),))
    gg_call(cm, unsafe_logdensityof, cfg, ctx, DropReturn())
end

@inline function tilde(::typeof(unsafe_logdensityof), lens, xname, x, d, cfg, ctx::NamedTuple)
    lm = lazymerge(cfg.obs, cfg.pars)
    x = getproperty(lm, xname)
    # x =get(lm, xname)
    @reset ctx.ℓ += MeasureBase.unsafe_logdensityof(d, lens(x))
    (x, ctx, ctx.ℓ)
end
