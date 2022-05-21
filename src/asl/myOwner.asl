/* Initial beliefs and rules */

state(5).
dinero(3000).

/* Initial goals */

!drink(beer). 

!bored.

!mood.

!ask_time.

!setupTool("Owner", "Robot").

/* Plans */

// if I have not beer finish, in other case while I have beer, sip

+!setupTool(Name, Id)
	<- 	makeArtifact("GUI","gui.Console",[],GUI);
		setBotMasterName(Name);
		setBotName(Id);
		focus(GUI). 
		
+say(Msg) <-
	.println("Owner esta aburrido y desde la consola le dice ", Msg, " al Robot");
	.send(myRobot,tell,msg(Msg)).
	
// Seg�n el estado del Owner comenta diferentes cosas cuando esta aburrido
+!bored: state(5) <-
	.println("Owner esta animado y le da conversaci�n al robot");
	.send(myRobot, tell, msg("Me encuentro animado"));
	.send(myRobot,tell,msg("Hola, �que haces?"));
	.wait(5000);
	!bored.
+!bored: state(4) <-
	.println("Owner esta euf�rico, y le da conversaci�n al robot");
	.send(myRobot, tell, msg("Me encuentro euf�rico"));
	.send(myRobot,tell,msg("Hola, que andas haciendo!"));
	.wait(5000);
	!bored.	
+!bored: state(3) <-
	.println("Owner esta crispado y le da conversaci�n al robot");
	.send(myRobot, tell, msg("Me encuentro crispado"));
	.send(myRobot,tell,msg("Que demonios haces!"));
	.wait(5000);
	!bored.	
+!bored: state(2) <-
	.println("Owner esta amodorrado y le da conversaci�n al robot");
	.send(myRobot, tell, msg("Me encuentro amodorrado"));
	.send(myRobot,tell,msg("�Que vas a zzZZ hacer hoy?"));
	.wait(5000);
	!bored.
+!bored: state(1) <-
	.println("Owner esta dormido y se escucha zzZZZ");
	.send(myRobot,tell,msg("zzZZ"));
	.random(R);	//se despierta en un tiempo aleatorio
	.wait(R * 5000 + 5000);
	-+state(4);
	//y recoge las latas
	//tambi�n recoge las latas de vez en cuando (no solo al despertar)
	!bored.
	
// Plan que se activa en un tiempo aleatorio
+!ask_time : true <-
   		.random(X); 
		.wait(X * 6000);
	    .println("El owner pregunta la hora");
		.send(myRobot, tell, msg("Que hora es"));
		!ask_time.

+!bored <- !bored.

+!drink(beer) : ~couldDrink(beer) <-
	.println("Owner ha bebido demasiado por hoy.").	
+!drink(beer) : not state(1) & has(myOwner,beer) & asked(beer) <-
	.println("Owner va a empezar a beber cerveza.");
	-asked(beer);
	sip(beer);
	?state(X);
	if(X<= 2){
		-+state(X+1);
		.println("el Owner ha bebido cerveza y aumenta un poco su estado de animo");
	}
	throw(beer);
	.println("El owner ha tirado una lata");
	!drink(beer).
+!drink(beer) : not state(1) & has(myOwner,beer) & not asked(beer) <-
	sip(beer);
	.println("Owner está bebiendo cerveza.");
	!drink(beer).
+!drink(beer) : not state(1) & not has(myOwner,beer) & not asked(beer) <-
	.println("Owner no tiene cerveza.");
	!get(beer);
	!drink(beer).
+!drink(beer) : not state(1) & not has(myOwner,beer) & asked(beer) <- 
	.println("Owner está esperando una cerveza.");
	.wait(5000);                                                                          
	!drink(beer).
+!drink(beer) <- !drink(beer).
	                                                                                                         
+!get(beer) : not asked(beer) <-
	.send(myRobot, achieve, bring(myOwner,beer)); //modificar adecuadamente
	//.send(myRobot, tell, msg("Necesito urgentemente una cerveza"));
	.println("Owner ha pedido una cerveza al robot.");
	+asked(beer). 
	
+!mood: true <-
	.random(R);
	.wait(R * 800 + 3000);
	?state(X);
	if(X \== 1){ //si no est� ya dormido
		if(X == 2){ //si va a pasar a dormido
			.send(myRobot, tell, msg("Voy a dormir en X msec"));
			.wait(5000);
		}
		-+state(X-1);
		.println("El owner esta perdiendo su estado de animo");
	}
	!mood.

+msg(M)[source(Ag)] <- 
	.print("Message from ",Ag,": ",M);
	+~couldDrink(beer);
	-msg(M).

+answer(Request) <-
	.println("El Robot ha contestado: ", Request);
	show(Request).
	
-answer(What) <- .println("He recibido desde el robot: ", What).

+!darDinero(X) : not state(1) & dinero(D) <-
	-+dinero(D-X);
	.send(myRobot, achieve, recibirDinero(X)).
