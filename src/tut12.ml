(* tut12.ml *)

(*

  \chapter{Comments}

  \cil{} has a very basic mechanism for tracking comments. In this chapter we'll
  see how to use it. \cil{} only sees comments when they are maintained in the
  output of the preprocessor. The preprocessor may be instructed to maintain
  comments in its output by using the \ttt{-C} switch to \program{ciltutcc}.
  Then, the comments in the source are collected by \cil{}'s parser and placed
  in the array [Cabshelper.commentsGA]. [commentsGA] is a [GrowArray.t] of
  triples of type ([Cabs.cabsloc * string *bool]). The [cabsloc] is the source
  location of the comment. The [string] is the comment itself, and the [bool] is
  set aside for application bookkeeping.


  \section{\texttt{tut12.ml}}

  In this example, we'll visit the AST and print out comments nearby
  instructions and statements, taking care to only print each comment once.
  This will be accomplished by extracting the source location from instructions
  and statements and then doing a binary search on the array of comments.
*)
open Cil (*r Some of our old friends *)
open Pretty
open Tututil
module S = String
module L = List
module GA = GrowArray

(*
  The array of comments lives in the [Cabshelper] module. The locations of the
  comments are defined in terms of the [Cabs.cabsloc] record type.
*)
module A = Cabs
module CH = Cabshelper

(*
  First, we'll need a few utility functions, some of which are hidden away in
  [Tututil] (e.g. functions for ordering source locations and comments).
  [prepareCommentArray] filters out comments not from source file [fname], and
  sorts the result according to source location.
*)
let prepareCommentArray (cca : comment array) (fname : string) : comment array =
  cca
  |> array_filter (fun (cl,_,_) -> fname = cl.A.filename)
  |> array_sort_result comment_compare

(*
  [commentsAdjacent] returns the indexes of at most two comments that are
  immediately adjacent to the given source location. The indexes are into the
  the array returned as the second element of the tuple.
*)
let commentsAdjacent (cca : comment array) (l : location)
                     : int list * comment array =
  if l = locUnknown then [], cca else
  let cca = prepareCommentArray cca l.file in
  (cca |> array_bin_search comment_compare (comment_of_cilloc l)), cca

(*
  [commentsBetween] returns a list of indexes into the array returned as the
  second element of the tuple. The indexes indicate the comments lying between
  source locations [l1] and [l2]. If the exact location is not in the comments
  array, the binary search function returns the two closest elements. Therefore
  [commentsBetween] returns the highest of the lower bounds, and the smallest of
  the upper bounds, so that only the indexes for the comments between the two
  locations are returned.
*)
let commentsBetween (cca : comment array) (l1 : location) (l2 : location)
                    : int list * comment array
  =
  if l1 = locUnknown then commentsAdjacent cca l2 else
  if l1.file <> l2.file then commentsAdjacent cca l2 else begin
  let cca = prepareCommentArray cca l1.file in
  let ll = array_bin_search comment_compare (comment_of_cilloc l1) cca in
  let hl = array_bin_search comment_compare (comment_of_cilloc l2) cca in
  let l, h =
    match ll, hl with
    | ([l] | [_;l]), h :: _ -> l, h
    | _ -> E.s(E.bug "bad result from array_bin_search")
  in
  (Array.init (h - l + 1) (fun i -> i + l) |> Array.to_list), cca
  end

(*
  [markComment] searches a [comment array] for an exact source location,
  and marks the third element of the tuple for that location as [true],
  indicating in this example that the comment has been printed by
  [printComments].
*)
let markComment (l : A.cabsloc) (cca : comment array) : unit =
  Array.iteri (fun i (l',s,b) ->
    if compare l l' = 0 then cca.(i) <- (l',s,true)
  ) cca

(*
  [printComments] prints the comments from the array [cca'] indicated by the
  indexes in [il] and marks the comments as having been printed in [cca].
  The location [l] is used to indicate the source location being inspected by
  an instance of the [commentVisitorClass] that triggered the call to
  [printComments].
*)
let printComments (cca : comment array) (l : location)
                  ((il,cca') : int list * comment array) : location =
  L.iter (fun i -> let c = cca'.(i) in
    if not(thd3 c) then begin
      markComment (fst3 c) cca;
      E.log "%a: Comment: %a -> %s\n"
        d_loc l d_loc (cilloc_of_cabsloc (fst3 c)) (snd3 c)
    end
  ) il;
  if il <> []
  then il |> L.rev |> L.hd |> Array.get cca' |> fst3 |> cilloc_of_cabsloc
  else l

(*
  The [commentVisitorClass] visits the AST, printing comments nearby
  instructions and statements.
*)
class commentVisitorClass (cca : comment array) = object(self)
  inherit nopCilVisitor

  val mutable last = locUnknown

  method vinst (i : instr) =
    last <- i
      |> get_instrLoc
      |> commentsBetween cca last
      |> printComments cca (get_instrLoc i);
    DoChildren

  method vstmt (s : stmt) =
    last <- s.skind
      |> get_stmtLoc
      |> commentsBetween cca last
      |> printComments cca (get_stmtLoc s.skind);
    DoChildren

end

(*
  Finally, we instantiate the visitor, and run it over the [Cil.file] passed as
  an argument.
*)
let tut12 (f : file) : unit =
  let cca = array_of_growarray CH.commentsGA in
  let vis = new commentVisitorClass cca in
  visitCilFile vis f

(*

  \input{../test/tut12}
  \normalfont\normalsize

  When we invoke \program{ciltutcc} on \file{tut12.c} as follows:

  \commands{\$~ciltutcc -{}-enable-tut12 -C -o tut12 test/tut12.c}

  We get the following output:

  \commands{test/tut12.c:7: Comment: test/tut12.c:3 ->  With this test, we'll see if CIL's parser successfully captures comments \\
test/tut12.c:7: Comment: test/tut12.c:7 ->  line comment x\\
test/tut12.c:12: Comment: test/tut12.c:8 ->  line comment y\\
test/tut12.c:12: Comment: test/tut12.c:11 ->  so far so good \\
test/tut12.c:15: Comment: test/tut12.c:14 ->  after the instr 
  }

  \section{Further Reading}

  Tan et al. have proposed that comparing the Natural Language semantics of
  comments with the Programming Language semantics of nearby code can reveal
  inconsistencies that could indicate the existence of
  bugs~\cite{butut12}{tan2,tan1}.

  \bibliographystyle{butut12}{plain}
  \bibliography{butut12}{ciltut}{References}
*)


