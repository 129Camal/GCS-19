/*
 * Linguagem: Linguagem para definir um sistema de pergunta e resposta
 * Processador: GIC que permite definir uma base de dados para um sistema de Pergunta e Resposta.
 * Frederico Pinto e Rui Vieira
 */

grammar DSL;

@header{
      import java.util.HashMap;
      import java.util.Map;
      import javafx.util.Pair; 
      import java.util.ArrayList;
}

@members{
      Map<String, Map<String, ArrayList<Pair<String,String>>>> baseDados = new HashMap<>();
      String yes = "Sim, é verdade!";
}


sistema: (restaurante)+ perguntas
       ;

restaurante: nome informacao[$nome.nomeRestaurante] 
           ;

nome returns[String nomeRestaurante] 
     : IDENT {
            $nome.nomeRestaurante = $IDENT.text;
            //System.out.println("Nome: " + $nome.nomeRestaurante);
            }
     ;

informacao [String nomeRestaurante] returns [Map<String, ArrayList<Pair<String, String>>> infRestaurante]
           @init{
                 $informacao.infRestaurante = new HashMap<String, ArrayList<Pair<String,String>>>();
                 baseDados.put($informacao.nomeRestaurante, $informacao.infRestaurante);
                 //System.out.println("Inicializei o hash para: " + $informacao.nomeRestaurante);
            }
          : triplo[$informacao.infRestaurante] (',' triplo[$informacao.infRestaurante])*
          ;


triplo [Map infRestaurante, Map<String, ArrayList<Pair<String, String>>> infRestaurante] returns [int sucess]
        @init{
            if(!$triplo.infRestaurante.containsKey("tem")){ $triplo.infRestaurante.put("tem", new ArrayList<Pair<String,String>>());}
            if(!$triplo.infRestaurante.containsKey("contacto")){ $triplo.infRestaurante.put("contacto", new ArrayList<Pair<String,String>>());}
            if(!$triplo.infRestaurante.containsKey("morada")){ $triplo.infRestaurante.put("morada", new ArrayList<Pair<String,String>>());}
            if(!$triplo.infRestaurante.containsKey("horario")){ $triplo.infRestaurante.put("horario", new ArrayList<Pair<String,String>>());}
        }
      : '{' 'tem' TEXTO '}' {       
                                    //System.out.println("tem: " + $TEXTO.text);
                                    Pair<String, String> parObjRes = new Pair<>($TEXTO.text, yes);
                                    ArrayList<Pair<String,String>> arrTem = $triplo.infRestaurante.get("tem");
                                    arrTem.add(parObjRes);
                                    }

      | '{' 'contacto' NUMERO '}'{    
                                    //System.out.println("contacto: " + Integer.toString($NUMERO.int));
                                    Pair<String, String> parObjRes = new Pair<>("\"" + Integer.toString($NUMERO.int) +"\"", yes);
                                    ArrayList<Pair<String,String>> arrTem = $triplo.infRestaurante.get("contacto");
                                    arrTem.add(parObjRes);
                                    }

      | '{' 'morada' TEXTO'}'{    
                                    //System.out.println("morada: " + $TEXTO.text);
                                    Pair<String, String> parObjRes = new Pair<>($TEXTO.text, yes);
                                    ArrayList<Pair<String,String>> arrTem = $triplo.infRestaurante.get("morada");
                                    arrTem.add(parObjRes);
                                    }

      | '{' 'horario' TEXTO '}' {    
                                    //System.out.println("horario: " + $TEXTO.text);
                                    Pair<String, String> parObjRes = new Pair<>($TEXTO.text, yes);
                                    ArrayList<Pair<String,String>> arrTem = $triplo.infRestaurante.get("horario");
                                    arrTem.add(parObjRes);
                                    }
      ;


perguntas: pergunta (',' pergunta)*
         ;

pergunta returns [String nomeRestaurante, String accao, String objeto]
        @init{
            $pergunta.nomeRestaurante = "null";
            $pergunta.accao = "null";
            $pergunta.objeto = "null";
        }
        : '[' TEXTO ']' { 
            
            for ( String key : baseDados.keySet() ) {
                   if($TEXTO.text.toLowerCase().contains(key.toLowerCase())){
                                                                             $pergunta.nomeRestaurante = key;
                                                                             //System.out.println($pergunta.nomeRestaurante);
                                                                             break;
                                                                             }
            }
            
            if($pergunta.nomeRestaurante.equals("null")){
                System.out.println("\n" + $TEXTO.text);                                            
                System.out.println("Restaurante não existe! Reformule a questão!");
                
            } else {
                Map<String, ArrayList<Pair<String,String>>> arrTem = baseDados.get($pergunta.nomeRestaurante);
                for(String key : arrTem.keySet()){
                    if($TEXTO.text.toLowerCase().contains(key.toLowerCase())){
                                                                              $pergunta.accao = key;
                                                                              //System.out.println($pergunta.accao);
                                                                              break;
                                                                              }
                }
                
                if($pergunta.accao.equals("null")){
                System.out.println("\n" + $TEXTO.text);
                System.out.println("Não percebemos o que quer saber sobre o restaurante! Reformule a questão!");
            
                } else {
                   ArrayList<Pair<String,String>> arrList = baseDados.get($pergunta.nomeRestaurante).get($pergunta.accao);
                   for(Pair<String,String> pair : arrList){
                       
                        if($TEXTO.text.toLowerCase().contains(pair.getKey().substring(1, (pair.getKey().length()-1)).toLowerCase())){
                                                                                        $pergunta.objeto = pair.getValue();
                                                                                        System.out.println("\n" + $TEXTO.text);
                                                                                        System.out.println($pergunta.objeto);
                                                                                        break;
                                                                              }
                   }
                   if($pergunta.objeto.equals("null")){
                        System.out.println("\n" + $TEXTO.text);
                        //System.out.println("Não sabemos informação suficiente para dizer que é verdade ou informação incompleta!");
                        System.out.println("Isto é o que sabemos sobre o assunto " + $pergunta.accao + " sobre "+ $pergunta.nomeRestaurante+":");
                        for(Pair<String,String> pair : arrList){
                            System.out.println(" -> " + pair.getKey().substring(1, (pair.getKey().length()-1)) + ";");
                        
                        }
                   }
                }
            }
           }
        
        ;


/* Definicao do Analisador LEXICO */

TEXTO: (('\"') ~('\"')* ('\"')); 

IDENT : LETRA(LETRA|[0-9-_/])* ;

fragment LETRA : [a-zA-ZáéíóúÁÉÍÓÚÃãÕõâêôÂÊÔÀÈÌÒÙàèìòùÇç] ;

Separador: ('\r'? '\n' | ' ' | '\t')+  -> skip;

NUMERO: ('0'..'9')+ ; // [0-9]+

HORA: [0-9]?[0-9] ':' [0-9][0-9];