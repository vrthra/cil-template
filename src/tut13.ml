(* tut13.ml *)

(*

  \chapter{Whole-program Analysis}

  \cil{} has a simple mechanism for allowing whole-program analysis. This
  mechanism is invoked when the \ttt{-{}-merge} switch is passed to
  \program{ciltutcc}. First, in the compilation phase, instead of compiling
  source code to an object file with the back-end compiler, the emitted
  \file{.o} file will contain the pre-processed source. Then, in the link
  stage, \program{ciltutcc} parses the \ttt{.o} files, and uses the \cil{}
  [Mergecil] module to combine the separate source files into a single
  [Cil.file]. More details of this process can be found in the official
  \cil{} documentation.


  \section{tut13.ml}

  In this tutorial, we'll see how to compute a whole-program call graph.
  The code in thie module is very simple since there is already a pretty good
  module for computing call graphs in \file{cil/src/ext/callgraph.ml}.
  Additionally, we'll use the \program{ocamlgraph} library to output a
  \file{.dot} file, which can be used to generate an image of the call-graph.
*)
open Cil
open Tututil
module H = Hashtbl
module CG = Callgraph

(*
  First we'll need to define a module for the graph using a functor from
  the graph library
*)
module SG = Graph.Imperative.Digraph.ConcreteBidirectional(struct
(*i*)
  type t = CG.callnode
  let hash n = H.hash n.CG.cnid
  let compare n1 n2 =
    compare n1.CG.cnid n2.CG.cnid
  let equal n1 n2 = 
    n1.CG.cnid = n2.CG.cnid
(*i*)
(* ... *)
end)

(*
  We'll also need to define a module that extends the graph module above with
  functions to define properties of vertices used by Dot to draw the graph.
  We'll just use the defaults. These functions can be modified to add more
  information to the graph.
*)
module D = Graph.Graphviz.Dot(struct
(*i*)
  type t = SG.t
  module V = SG.V
  module E = SG.E
  let iter_vertex = SG.iter_vertex
  let iter_edges_e = SG.iter_edges_e
  let graph_attributes g = []
  let default_vertex_attributes g = []
  let vertex_name v =
    match v.CG.cnInfo with
    | CG.NIVar (vi, _) -> vi.vname
    | CG.NIIndirect (s, _) -> s
  let vertex_attributes v = []
  let get_subgraph v = None
  let default_edge_attributes g = []
  let edge_attributes e = []
(*i*)
(* ... *)
end)

(*
  The [graph_of_callgraph] functions converts a \cil{} call-graph into an
  \program{ocamlgraph} graph that we can use to generate the \file{.dot} file.
*)
let graph_of_callgraph (cg : CG.callgraph) : SG.t =
  let g = SG.create () in
  H.iter (fun s n -> SG.add_vertex g n) cg;
  H.iter (fun s n ->
    Inthash.iter (fun i n' ->
      SG.add_edge g n n'
    ) n.CG.cnCallees
  ) cg;
  g

(*
  Now, we'll compute the call-graph, convert it to a graph for the graph
  library, and pass it to the graph library function that produces the
  \file{.dot} file.
*)
let tut13 (f : file) : unit =
  let o = open_out !Ciltutoptions.tut13out in
  f |> CG.computeGraph |> graph_of_callgraph |> D.output_graph o;
  close_out o

(*

  \section{Example}

  The difficult part of arranging for whole-program analysis is the more
  complicated compilation process. Here are two source files that we'll use
  to generate one call-graph:

  In the first file, we'll declare an \ttt{extern} function \ttt{bar} and
  define a function \ttt{foo} that calls it.

  \input{../test/tut13a}
  \normalfont\normalsize

  In the second file, we'll make an \ttt{extern} declaration for the function
  \ttt{foo}, and define the function \ttt{bar} that in turn calls \ttt{foo}. The
  \ttt{main} function simply calls \ttt{bar}. (Obviously, this program is a
  nonsense example.)

  \input{../test/tut13b}
  \normalfont\normalsize

  Now we can build this program with the whole program analysis by executing
  the following commands:

  \commands{\$~ciltutcc -{}-merge -o tut13a.o -c test/tut13a.c\\
            \$~ciltutcc -{}-merge -o tut13b.o -c test/tut13b.c\\
            \$~ciltutcc -{}-merge -{}-enable-tut13 -{}-tut13-out tut13.dot -o tut13 tut13a.o tut13b.o}

  Then, we can generate a graph from the \file{.dot} file as follows:

  \commands{\$~dot -Tpdf tut13.dot -o tut13.pdf}

  to produce the graph in Figure~\ref{fig:callgraph}. Which is the call-graph
  for the whole program.

  \begin{figure}
  \begin{center}
  \includegraphics{callgraph.pdf}
  \caption{The call-graph for \file{tut13a.c} and \file{tut13b.c}}
  \label{fig:callgraph}
  \end{center}
  \end{figure}
*)

