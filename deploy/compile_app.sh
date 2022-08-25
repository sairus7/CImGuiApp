julia -e 'using Pkg; Pkg.add("PackageCompiler")'

julia --project=@. --startup-file=no -e '
using Pkg; 
Pkg.add(name="CImGui", rev="master");
Pkg.add(name="ImPlot", rev="main");
Pkg.instantiate()
'

julia --project=@. --startup-file=no -e '
using PackageCompiler;
PackageCompiler.create_app(pwd(), "CImGuiAppCompiled";
    cpu_target="generic;sandybridge,-xsaveopt,clone_all;haswell,-rdrnd,base(1)",
    include_transitive_dependencies=false,
    filter_stdlibs=true,
    precompile_execution_file=["test/runtests.jl"])
'
