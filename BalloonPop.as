package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class BalloonPop extends MovieClip {
		
		// display objects
		private var balloons:Array;
		private var rocketIcons:Array;
		private var cannonball:Cannonball;
		private var rocket:Rocket;
		private var cannonballDX, cannonballDY:Number;
		private var missiles:Array;
		private var ship:Cannonbase;
		private var shipGun:Cannon;
		private var planes:Array;
		private var newPlane:MovieClip;
		
		
		private var snd:Sound;
		private var rocketSnd:Sound;
		private var expSnd:Sound;
		private var req:URLRequest;
		private var roc:URLRequest;
		private var exp:URLRequest;
		
		//private var song:SoundChannel;
		
		

		
		// keys
		private var leftArrow, rightArrow, downArrow, upArrow, bonb:Boolean;
		
		// game properties
		private var shotsUsed:int;
		private var points:int;
		private var rocketLeft:int;
		private var speed:Number;
		private var speedPlane:Number;
		private var gameLevel:int;
		private const gravity:Number = 0.01;
		
		public function startBalloonPop() {
			gameLevel = 1;
			shotsUsed = 50;
			rocketLeft =4;
			speed = 10;
			points=0;
			missiles = new Array();
			createShip();
			nextWave();
			movePlane();
			createSounds();
			createRocketIcons();
			gotoAndStop(2);
		}
		public function createSounds()
		{
			snd = new Sound();
			req = new URLRequest("sound/gun_sound.mp3");
			snd.load(req);
			//song = new SoundChannel();
			expSnd = new Sound();
			exp = new URLRequest("sound/explosion2.mp3");
			expSnd.load(exp);
			rocketSnd = new Sound();
			roc = new URLRequest("sound/rocket.mp3");
			rocketSnd.load(roc);
		}
		public function startLevel() {
			showGameScore();
			
			// listen for keyboard
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			
			// look for collisions
			addEventListener(Event.ENTER_FRAME,gameEvents);

		}
		
		public function createShip()
		{ 
			ship = new Cannonbase();
			shipGun = new Cannon();
			ship.x = 282;
			ship.y = 359;
			shipGun.x = 280;
			shipGun.y = 311;
			addChild(shipGun);
			addChild(ship);
		}
		
		public function createPlane(nmb:int)
		{
			for(var i:int=0; i< nmb; i++)
			{
			newPlane = new Plane();
			newPlane.gotoAndStop(Math.ceil(Math.random()*3));
			addChild(newPlane);
			newPlane.x=-1000*i;
			newPlane.y=(Math.ceil(Math.random()*100)+40);
			planes.push(newPlane);
			speedPlane = Math.ceil(Math.random()*8);
			}
			for(var z:int=0; z< nmb; z++)
			{
			newPlane = new PlanesLeft();
			newPlane.gotoAndStop(Math.ceil(Math.random()*3));
			addChild(newPlane);
			newPlane.x= 1000*z;
			newPlane.y=(Math.ceil(Math.random()*100)+40);
			planes.push(newPlane);
			speedPlane = 6;
			} 
					
		}
			
			
		public function movePlane()
		{	
			
			
			for(var i:int=planes.length-1;i>=0;i--) 
			{
				
				if(planes[i] is Plane)
				{
				planes[i].x += speedPlane/2;
				}
				else if (planes[i] is PlanesLeft)
				{
					planes[i].x -= speedPlane*1.2;
				}
					
				if (planes[i].currentFrame == 1 || planes[i].currentFrame == 2 || planes[i].currentFrame == 3 )
				{
					if (bonb)
					{
						planes[i].gotoAndStop(4);
					}
				}
				else if (planes[i].currentFrame == 4 && !bonb)
				{
					planes[i].gotoAndStop(Math.ceil(Math.random()*3));
				}
				
				
			}
			
			
		}
		public function nextWave() 
		{
			planes = new Array();
			createPlane(20);
			
			
		}
				
		public function gameEvents(event:Event) {
			moveCannon();
			movePlane();
			moveCannonball();
			moveRocket();
			showGameScore();
			checkForHits();
		}
		
		
		public function moveCannon() {
			var newRotation = shipGun.rotation;
			
			if (leftArrow) {
				newRotation -= 1;
			}
			
			if (rightArrow) {
				newRotation += 1;
			}
			
			// check boundaries
			if (newRotation < -90) newRotation = -90;
			if (newRotation > 90) newRotation = 90;
			
			// reposition
			shipGun.rotation = newRotation;
		}
		
		public function fireRocket()
		{
			if (rocket !=null) return;
			
			if(rocketLeft > 0)
			{
				rocketLeft--;
				rocket = new Rocket();
				rocket.x = shipGun.x;
				rocket.y = shipGun.y
				addChild(rocket);
				showGameScore();
				removeRocketIcon();
				rocketSnd.play();
			}
			
		}
		
		public function moveRocket()
		{
			var speedRocket=1;
			if(rocket !=null)
			
			{	
				
				if(downArrow)
				{
				speedRocket = 0.5;
				}
				if (upArrow)
				{
				speedRocket=5.5;
				}
				
				
				rocket.x += speedRocket*Math.cos(2*Math.PI*(shipGun.rotation-90)/360)*1.5;
				rocket.y += speedRocket*Math.sin(2*Math.PI*(shipGun.rotation-90)/360);
				
				if (rocket.y < -100 || rocket.x > 550 || rocket.y > 400 || rocket.x <0) 
				{
					removeChild(rocket);
					rocket =null;
				}
			}
			
		}
		public function fireCannon() 
		{
			
			if(shotsUsed > 0)
			{
				shotsUsed--;
				// create cannonball 
			cannonball = new Cannonball();
			cannonball.x = shipGun.x;
			cannonball.y = shipGun.y;
			addChild(cannonball);
			
			showGameScore();
			// move cannon and base above ball
			addChild(shipGun);
			addChild(ship);
			addChild(newPlane);
			
			missiles.push(cannonball);
			// set direction for cannonball
			cannonballDX = speed*Math.cos(2*Math.PI*(shipGun.rotation-90)/360);
			cannonballDY = speed*Math.sin(2*Math.PI*(shipGun.rotation-90)/360);
			snd.play();
			}
			else 
			{
				cleanUp();
				endGame();
			}
			
		}       
		
		
		public function moveCannonball() 
		{
			for(var i:int=0; i<missiles.length;i++) 
			{
				missiles[i].x += cannonballDX;
				missiles[i].y += cannonballDY;
						
						// add pull of gravity
				missiles[i].y += gravity;
							
						// see if the ball hit the ground
					
				if (missiles[i].y < 0 || missiles[i].x > 550 
					|| missiles[i].x < 0 || missiles[i].y > 400) 
				{
					removeChild(missiles[i]);
					missiles.splice(i,1);
							//delete missiles[i];
				}
			}
			 
		}
				
		
		// check for collisions
		public function checkForHits() 
		{					
				
				for (var i:int=planes.length-1;i>=0;i--) 
				{
					for(var j:int=0; j<missiles.length;j++)
					// see if it is touching the cannonball
					{
						if(Point.distance(new Point(planes[i].x,planes[i].y),
							new Point(missiles[j].x,missiles[j].y))< 40)
						{	points += 10;
							playSound();
							planes[i].gotoAndPlay(5);
							//break;
						}
					}
					if (rocket != null && Point.distance(new Point(planes[i].x,planes[i].y),
							new Point(rocket.x,rocket.y))< 60)
					{		points += 10;
							playSound();
							planes[i].gotoAndPlay(5);
							break;
					}
				}
			
		}
		public function playSound()
		{
			expSnd.play();
		}
		
		// key pressed
		public function keyDownFunction(event:KeyboardEvent) {
			if (event.keyCode == 37) {
				leftArrow = true;
			} else if (event.keyCode == 39) {
				rightArrow = true;
			} else if (event.keyCode == 32) {
				fireCannon();
			} else if (event.keyCode == 88)
			{
				fireRocket();
			} else if (event.keyCode == 40)
			{
				downArrow = true;
			}else if (event.keyCode == 38)
			{
				upArrow = true;
			}else if (event.keyCode == 66) { 
					bonb = true;
			}
		}
		
		// key lifted
		public function keyUpFunction(event:KeyboardEvent) {
			if (event.keyCode == 37) {
				leftArrow = false;
			} else if (event.keyCode == 39) {
				rightArrow = false;
			} else if (event.keyCode == 40)
			{
				downArrow = false;
			}else if (event.keyCode == 38)
			{
				upArrow = false;
			}else if (event.keyCode == 66) { 
					bonb = false;
			}
		}
		
		
		public function createRocketIcons() 
		{
			rocketIcons = new Array();
			for(var i:uint=0;i<rocketLeft;i++) 
			{
				var newRocket:RocketIcon = new RocketIcon();
				newRocket.x = 500+i*15;
				newRocket.y = 375;
				addChild(newRocket);
				rocketIcons.push(newRocket);
			}
		}
		public function removeRocketIcon() {
			removeChild(rocketIcons.pop());
		}
			
		// balloons call back to here to get removed
		public function balloonDone(thisBalloon:MovieClip) {
			
			// remove from screen
			removeChild(thisBalloon);
			
			// find in array and remove
			for(var i:int=0;i<planes.length;i++) {
				if (planes[i] == thisBalloon) {
					planes.splice(i,1);
					break;
				}
			}
			
			// see if all balloons are gone
			if (planes.length == 0) {
				cleanUp();
				if (gameLevel == 3) {
					endGame();
				} 
			}
		} 
		
		// stop the game
		public function cleanUp() {
			
			// stop all events
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			removeEventListener(Event.ENTER_FRAME,gameEvents);
						
			for(var i:int=missiles.length-1;i>=0;i--) 
			{	
				removeChild(missiles[i]);
			}
            
			for(var z:int=planes.length-1;z>=0;z--) 
			{	
				if(planes[z] != null)
				{
					removeChild(planes[z]);
					//planes[z]= null;
					
				}
				//planes.splice(z,1);
			}
			// remove the cannon
				removeChild(ship);
				removeChild(shipGun);
				ship = null;
				shipGun=null;
				bonb = false;
		}

		
		
		public function endGame() {
			gotoAndStop("gameover");
		}

		
		
		public function showGameScore() {
			showScore.text = String("Shots: "+shotsUsed);
			score.text = String("Score: " + points);
		}
		
	}
}