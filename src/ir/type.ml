
type field_spec =
   Field_spec of string list * sisal_type
and
field =
   Field of field_name list
and field_name = Field_name of string
and
  field_exp = Field_exp of field * exp
and
  field_def = Field_def of field_name * exp
and expr_pair = Expr_pair of exp * exp
and type_def = Type_def of type_name * sisal_type
and tag_exp = Tag_name of tag_name | Tag_exp of tag_name * exp
and iterator_terminator = Iterator_termination of iterator * termination_test
                          | Termination_iterator of termination_test * iterator
and iterator = Repeat of decldef_part
and termination_test = While of exp | Until of exp
and def = Def of string list * exp
and decl = Decl of string list * sisal_type  
and decldef = Decl_def of def
              | Decl_decl of decl
              | Decldef of decl list * exp
and simple_exp =
  Constant of sisal_constant
  | Old of value_name
  | Val of value_name
  | Paren of exp
  | Invocation of function_name * arg
  | Array_ref of simple_exp * exp
  | Array_generator_named of type_name
  | Array_generator_unnamed of expr_pair
  | Array_generator_named_addr of type_name * expr_pair
  | Array_generator_primary of simple_exp * expr_pair list
  | Stream_generator of type_name
  | Stream_generator_exp of type_name * exp
  | Record_ref of simple_exp * field_name
  | Record_generator_named of type_name * field_def list
  | Record_generator_unnamed of field_def list
  | Record_generator_primary of simple_exp * field_exp list
  | Is of tag_name * exp
  | Union_generator of type_name * tag_exp
  | Is_error of exp
  | Prefix_operation of prefix_name * exp
  | If of (cond list) * last_else 
  | Let of decldef_part * exp
  | Tagcase of
      tagassign_exp * tagnames_colon_exp list * otherwise
  | For_all of in_exp * decldef_part * (return_clause list)
  | For_initial of decldef_part * iterator_terminator * (return_clause list)
  | Not of simple_exp
  | Negate of simple_exp
  | Pipe of  simple_exp * simple_exp
  | And of simple_exp * simple_exp
  | Divide of simple_exp * simple_exp
  | Multiply of simple_exp * simple_exp
  | Or of simple_exp * simple_exp
  | Subtract of simple_exp * simple_exp
  | Add of simple_exp * simple_exp
  | Not_equal of simple_exp * simple_exp
  | Equal of simple_exp * simple_exp
  | Lesser_equal of simple_exp * simple_exp
  | Lesser of simple_exp * simple_exp
  | Greater_equal of simple_exp * simple_exp
  | Greater of simple_exp * simple_exp 
and exp = Exp of simple_exp list | Empty
and cond = Cond of exp * exp
and last_else = Else of exp
and otherwise = Otherwise of exp
and tagassign_exp = Assign of value_name * exp | Tagcase_exp of exp
and tagnames = Tagnames of string list
and tagnames_colon_exp = Tag_list of tagnames * exp
and arg = Arg of exp
and function_name = Function_name of string
and function_header =
    Function_header of function_name * decl list * sisal_type list
  | Function_header_nodec of function_name * sisal_type list
and function_def = Forward_function of function_header
  | Function of function_leaf list
and function_leaf = Function_single of (function_header * (type_def list) * (function_leaf list) * exp)
and define = Define of function_name list
and compilation_unit = Compilation_unit of define * (type_def list) * (function_header list) * function_def list
and fun_returns = Returns of sisal_type list
and decldef_part = Decldef_part of decldef list
and reduction_op = Sum | Product | Least | Greatest | Catenate | No_red
and direction_op = Left | Right | Tree | No_dir
and in_exp = In_exp of value_name * exp
             | At_exp of in_exp * value_name
             | Dot of in_exp * in_exp
             | Cross of in_exp * in_exp
and value_name = Value_name of string
and return_exp = Value_of of direction_op * reduction_op * exp
                    | Array_of of exp | Stream_of of exp
and masking_clause = Unless of exp | When of exp | No_mask
and return_clause =
    Return_exp of return_exp * masking_clause
  | Old_ret of  return_exp * masking_clause
and
sisal_constant = 
  False | Nil | True | Int of int
  | Float of float | Char of string
  | String of string | Error of sisal_type 
and
  prefix_name = Char_prefix | Double_prefix | Integer_prefix | Real_prefix
and
  sisal_type = 
    Boolean
  | Character
  | Double_real
  | Integer
  | Null
  | Real
  | Compound_type of compound_type
  | Type_name of type_name
and
  compound_type =
  Sisal_array  of sisal_type
  | Sisal_stream of sisal_type
  | Sisal_record of (field_spec list)
  | Sisal_union  of (string list * sisal_type)
  | Sisal_union_enum  of (string list)
and tag_name = string
and type_name = string

(* Stringify *)

let mysplcon a b cha =
match b with 
| "" -> a
| _ -> (match a with 
  | "" -> b
  | _ -> a ^ cha ^ b)

let myfold c = 
  List.fold_left (fun last fs -> (mysplcon last fs c)) ""

let semi_fold = myfold ";" 
let semi_nl_fold = myfold ";\n" 
let comma_fold = myfold ","
let spc_fold = myfold " "
let nl_fold = myfold "\n"
let dot_fold = myfold "."
let paren exp = "(" ^ exp ^ ")"
let brack exp = "[" ^ exp ^ "]"
let elseif_fold = myfold "\nELSE IF "
let rec
  str_tagnames = function
  | Tagnames tn -> comma_fold tn
and str_direction = function
  | No_dir -> ""
  | Left -> "LEFT"
  | Right -> "RIGHT"
  | Tree -> "TREE"
and str_reduction = function
  | Sum -> "SUM"
  | Product -> "PRODUCT"
  | Least -> "LEAST"
  | Greatest -> "GREATEST"
  | Catenate -> "CATENATE"
  | No_red -> ""
and str_return_exp = function
  | Value_of (d,r,e) ->
    spc_fold ["VALUE OF"; str_direction d; str_reduction r;str_exp e]
  | Array_of e -> "ARRAY OF " ^ (str_exp e)
  | Stream_of e -> "STREAM OF " ^ (str_exp e)
and str_masking_clause = function
  | Unless e -> "UNLESS " ^ (str_exp e)
  | When e -> "WHEN " ^ (str_exp e)
  | No_mask -> ""
and str_iterator = function
  | Repeat dp -> "REPEAT\n" ^ (str_decldef_part dp)
and str_termination = function
  | While e -> "WHILE " ^ (str_exp e)
  | Until e -> "UNTIL " ^ (str_exp e)
and str_return_clause = function
  | Old_ret (re,mc) ->
    spc_fold ["OLD"; str_return_exp re; str_masking_clause mc]
  | Return_exp (re,mc) ->
    spc_fold [str_return_exp re; str_masking_clause mc]
and str_taglist = function
  |  Tag_list (tns,e) -> "TAG " ^ (str_tagnames tns) ^ ":" ^ (str_exp e)
and str_taglist_list tls = nl_fold (List.map str_taglist tls)
and str_tagcase_exp = function
  |Assign (vn, e) -> "TAGCASE " ^ (str_val vn) ^ ":=" ^ (str_exp e)
  | Tagcase_exp (exp) -> "TAGCASE " ^ (str_exp exp)
and str_otherwise = function
  | Otherwise e -> "OTHERWISE " ^ (str_exp e)
and str_field_spec = function
| Field_spec (sl,s) -> (comma_fold sl) ^ ":" ^ (str_sisal_type s)
and str_compound_type = function
  | Sisal_array s -> "ARRAY [" ^ str_sisal_type s ^ "]"
  | Sisal_stream s -> "STREAM [" ^ str_sisal_type s ^ "]"
  | Sisal_union  (stl, s) ->
    (mysplcon ("UNION [" ^ (comma_fold stl)) (str_sisal_type s) ":") ^ "]"
  | Sisal_union_enum  (stl) -> "UNION [" ^ (comma_fold stl) ^ "]"
  | Sisal_record ff -> "RECORD [" ^ (semi_fold (List.map str_field_spec ff)) ^ "]"
and
  str_sisal_type = function 
  | Boolean -> "BOOLEAN"
  | Character -> "CHARACTER"
  | Double_real -> "DOUBLE_REAL"
  | Integer -> "INTEGER"
  | Null -> "NULL"
  | Real -> "REAL"
  | Compound_type ct -> 
    str_compound_type ct
  | Type_name ty -> ty
and
  str_constant = function
  | False -> "FALSE" | Nil -> "NIL" | True -> "TRUE" | Int i -> string_of_int i
  | Float f -> string_of_float f | Char st -> "\"" ^ st  ^ "\""
  | String st -> "\"" ^ st ^ "\""
  | Error st -> "ERROR [" ^ (str_sisal_type st) ^ "]"
and
  str_val = function | Value_name v -> v
and
  str_exp = function
  | Exp e -> comma_fold (List.map str_simple_exp e)
  | Empty -> ""
and
  str_exp_pair = function
  | Expr_pair (e,f) -> (str_exp e) ^ ":" ^ (str_exp f)
and str_field_name = function 
  | Field_name f -> f
and str_field_exp = function
  | Field_exp (f,e) -> (str_field f) ^ ":" ^ (str_exp e)
and str_field = function
  | Field fl -> dot_fold (List.map str_field_name fl)
and str_field_def = function
  | Field_def (fn,ex) -> (str_field_name fn) ^ ":" ^ (str_exp ex)
and str_cond = function
  | Cond (c,e) -> (str_exp c) ^ " THEN\n" ^ (str_exp e)
and str_in_exp = function
  | In_exp (vn,e) -> (str_val vn) ^ " IN " ^ (str_exp e)
  | At_exp (ie,vn) -> (str_in_exp ie) ^ " AT " ^ (str_val vn)
  | Dot (ie1,ie2) -> (str_in_exp ie1) ^ " DOT " ^ (str_in_exp ie2)
  | Cross (ie1,ie2) -> (str_in_exp ie1) ^ " CROSS " ^ (str_in_exp ie2)
and str_if f = (elseif_fold (List.map str_cond f))
and str_else = function
  | Else e -> "ELSE " ^ (str_exp e)
and str_tag_exp = function
  Tag_name tn -> tn
  | Tag_exp (tn,exp) -> tn ^ ":" ^ (str_exp exp)
and str_prefix_name = function
  | Char_prefix -> "CHAR"
  | Double_prefix -> "DOUBLE"
  | Integer_prefix -> "INTEGER"
  | Real_prefix -> "REAL"
and str_decldef_part = function
  | Decldef_part f -> semi_nl_fold (List.map str_decldef f)
and str_def = function
  | Def (x,y) -> (comma_fold x)
                  ^ " := " ^ (str_exp y)
and str_decl = function
  | Decl(x,y) -> (comma_fold x) ^ ":" ^ (str_sisal_type y)
and str_decldef = function
  | Decl_def x -> str_def x
  | Decl_decl x -> str_decl x
  | Decldef (x,y) -> (comma_fold (List.map str_decl x)) ^ " := " ^ (str_exp y)
and str_function_name = function
  | Function_name f -> f
and str_arg = function | Arg e -> str_exp e
and str_simple_exp = function
  | Constant x -> str_constant x
  | Old v -> "OLD " ^ (str_val v)
  | Val v -> str_val v
  | Paren e -> "(" ^ str_exp e ^ ")"
  | Invocation(fn,arg) ->
    (str_function_name fn) ^ "(" ^ (str_arg arg) ^ ")"
  | Not e -> "~" ^ (str_simple_exp e)
  | Negate e -> "-" ^ (str_simple_exp e)
  | Pipe (a,b) -> (str_simple_exp a) ^ " || " ^ (str_simple_exp b)
  | And (a,b) -> (str_simple_exp a) ^ " & " ^ (str_simple_exp b)
  | Divide (a,b) -> (str_simple_exp a) ^ " / " ^ (str_simple_exp b)
  | Multiply (a,b) -> (str_simple_exp a) ^ " * " ^ (str_simple_exp b)
  | Subtract (a,b) -> (str_simple_exp a) ^ " - " ^ (str_simple_exp b)
  | Add (a,b) -> (str_simple_exp a) ^ " + " ^ (str_simple_exp b)
  | Or (a,b) -> (str_simple_exp a) ^ " | " ^ (str_simple_exp b)
  | Not_equal (a,b) -> (str_simple_exp a) ^ " ~= " ^ (str_simple_exp b)
  | Equal (a,b) -> (str_simple_exp a) ^ " = " ^ (str_simple_exp b)
  | Lesser_equal (a,b) -> (str_simple_exp a) ^ " <= " ^ (str_simple_exp b)
  | Lesser (a,b) -> (str_simple_exp a) ^ " < " ^ (str_simple_exp b)
  | Greater_equal (a,b) -> (str_simple_exp a) ^ " >= " ^ (str_simple_exp b)
  | Greater (a,b) -> (str_simple_exp a) ^ " > " ^ (str_simple_exp b)
  | Array_ref (se,e) -> (str_simple_exp se) ^ "[" ^ (str_exp e) ^ "]"
  | Array_generator_named tn -> "ARRAY " ^ tn ^ "[]"
  | Array_generator_named_addr (tn,ep) ->
    "ARRAY " ^ tn ^ " [" ^ (str_exp_pair ep) ^ "]"
  | Array_generator_unnamed ep -> "ARRAY " ^ " [" ^ (str_exp_pair ep) ^ "]"
  | Array_generator_primary (p,epl) ->
    spc_fold ["ARRAY"; str_simple_exp p; "["; semi_fold (List.map str_exp_pair epl); "]"]
  | Record_ref (e,fn) ->
    (str_simple_exp e) ^ "." ^ (str_field_name fn)
  | Record_generator_primary (e,fdle) ->
    spc_fold [str_simple_exp e; "REPLACE ["; (semi_fold (List.map str_field_exp fdle)); "]"]
  | Record_generator_unnamed (fdl) ->
    spc_fold ["RECORD"; semi_fold (List.map str_field_def fdl)]
  | Record_generator_named (tn,fdl) ->
    spc_fold ["RECORD"; tn;  semi_fold (List.map str_field_def fdl)]
  | Stream_generator tn -> "STREAM " ^ tn ^ "[]"
  | Stream_generator_exp (tn,e) -> "STREAM " ^ tn
                                    ^ "[" ^ (str_exp e) ^ "]"
  | Is (tn,e) -> 
    "IS " ^ tn ^ "(" ^ (str_exp e) ^ ")"
  | Union_generator (tn,te) ->
    spc_fold ["UNION"; tn; "["; str_tag_exp te; "]"]
  | Prefix_operation (pn,e) -> (str_prefix_name pn) ^ "(" ^ (str_exp e) ^ ")"
  | Is_error e -> "IS ERROR (" ^ (str_exp e) ^ ")"
  | Let (dp,e) -> nl_fold["LET"; str_decldef_part dp;"IN"; str_exp e; "END LET"]
  | Tagcase (ae,tc,o) ->
    nl_fold [str_tagcase_exp ae; str_taglist_list tc; str_otherwise o]
  | If (cl, el) -> nl_fold[ "IF"; str_if cl; str_else el; "END IF"]
  | For_all (i,d,r) -> 
    nl_fold
      ["FOR " ^ 
       (str_in_exp i);
       str_decldef_part d;
       "RETURNS";
       spc_fold (List.map str_return_clause r);
      "END FOR"]
  | For_initial (d,i,r) -> 
    let loopAOrB i = match i with 
      | Iterator_termination (ii,t) ->
        nl_fold ["FOR INITIAL " ^ 
                  (str_decldef_part d);
                  str_iterator ii;
                  str_termination t;
                  "RETURNS";
                  spc_fold (List.map str_return_clause r);
                 "END FOR"]
      | Termination_iterator (t,ii) ->
        nl_fold ["FOR INITIAL " ^ 
                  (str_decldef_part d);
                  str_termination t;
                  str_iterator ii;
                  "RETURNS";
                  spc_fold (List.map str_return_clause r);
                 "END FOR"]
    in loopAOrB i
and str_type_list tl  = (comma_fold (List.map str_sisal_type tl))
and str_defines = function
  | Define dn -> "DEFINE " ^ comma_fold (List.map str_function_name dn)
and str_global f = "GLOBAL " ^ (str_function_header f)
and str_compilation_unit = function
  | Compilation_unit (defines,type_defs,globals,fdefs) ->
    nl_fold
      [str_defines defines;
       semi_nl_fold (List.map str_type_def type_defs);
       nl_fold (List.map str_global globals);
       nl_fold (List.map
       str_function_def fdefs)]
and str_type_def = function
  | Type_def (n,t) ->
    spc_fold ["TYPE";n;"="; str_sisal_type t]
and internals f =
  match f with
  |  [] -> ""
  | (Function_single (header,tdefs,nest,e))::tl ->
    ("FUNCTION " ^
    (nl_fold [ str_function_header header;
               semi_nl_fold (List.map str_type_def tdefs);
               internals nest;
               str_exp e;
               "END FUNCTION"])) ^ ( internals tl)
and str_function_def = function
  | Function f -> internals f
  | Forward_function f -> "FORWARD FUNCTION " ^ (str_function_header f)
and str_function_header = function
  | Function_header_nodec (fun_name,tl) -> 
    spc_fold
      [(str_function_name fun_name);
       paren ("RETURNS " ^  (str_type_list tl))]
  | Function_header (fun_name,decls,tl) ->
    spc_fold
      [str_function_name fun_name;
       paren ((semi_fold (List.map str_decl decls))
              ^ "\n   RETURNS "  ^ (str_type_list tl))]

