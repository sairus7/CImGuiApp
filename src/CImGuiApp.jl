module CImGuiApp

using CImGui
using ImPlot
#include(joinpath(pathof(ImPlot), "..", "..", "demo", "Renderer.jl"))
include("Renderer.jl")
using .Renderer
using CImGui.CSyntax

export show_gui

const USERDATA = Dict{String, Any}(
    "xy1" => (zeros(Float32, 1001), zeros(Float32, 1001)),
    "xy2" => (zeros(Float32, 11), zeros(Float32, 11)), 
)

const STORAGE = Dict{UInt32, Any}()
get_uistate(key::String, default = nothing) = get(STORAGE, CImGui.GetID(key), default)
set_uistate(key::String, value) = STORAGE[CImGui.GetID(key)] = value

function test_buttons()
    for i = 1:3
        n = get_uistate("counter_$i", 0)
        if CImGui.Button("Clicked $n times###$i") 
            n += 1
            set_uistate("counter_$i", n)
            #@show n
        end
    end
    if CImGui.Button("Reset")
        for i = 1:3
            set_uistate("counter_$i", 0)
        end
    end
end

function ui()
    CImGui.Begin("Window")

    xs1, ys1 = USERDATA["xy1"]
    xs2, ys2 = USERDATA["xy2"]
    
    check = get_uistate("time_checkbox", false)
    if @c CImGui.Checkbox("Click me to animate plot", &check)
        set_uistate("time_checkbox", check)
    end
    if check
        DEMO_TIME = CImGui.GetTime()
        for i in eachindex(xs1)
            xs1[i] = (i - 1) * 0.001
            ys1[i] = 0.5 + 0.5 * sin(50 * (xs1[i] + DEMO_TIME / 10))
        end
        for i in eachindex(xs2)
            xs2[i] = (i - 1) * 0.1
            ys2[i] = xs2[i] * xs2[i]
        end
    end

    CImGui.BulletText("Anti-aliasing can be enabled from the plot's context menu (see Help).")
    if ImPlot.BeginPlot("Line Plot", "x", "f(x)")
        ImPlot.PlotLine("sin(x)", xs1, ys1, length(xs1))
        ImPlot.SetNextMarkerStyle(ImPlotMarker_Circle)
        ImPlot.PlotLine("x^2", xs2, ys2, length(xs2))
        ImPlot.EndPlot()
    end

    test_buttons()

    CImGui.End()
end

function show_gui()
    Renderer.render(
        ui, # function object
        width = 1360, 
        height = 780, 
        title = "", 
    )
end

function julia_main()::Cint
    try
        t = show_gui()
        wait(t)
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0 # if things finished successfully
end

end
