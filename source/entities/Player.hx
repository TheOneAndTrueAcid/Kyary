package entities;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.util.loaders.TexturePackerData;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import managers.TimeMaster;

/**
 * ...
 * @author Acid
 */
class Player extends FlxSprite
{
	
	@:isVar public var bulletGroup(get, null):FlxTypedGroup<Bullet>;
	@:isVar public var shotAnim(get,null):FlxSprite;
	@:isVar public var heart(get,null):FlxSprite;
	@:isVar public var hurtSFX(get,null):FlxSound;
	@:isVar public var shootSFX(get, null):FlxSound;
	public var canPlay:Bool = false;
	private var isFocused:Bool = false;

	public function new(X:Float=0, Y:Float=0) {
		super(X, Y);		
		
		hurtSFX = FlxG.sound.load("assets/sounds/explode.wav", 1, false);
		shootSFX = FlxG.sound.load("assets/sounds/shoot.wav", 1, false);
		
		var tex:TexturePackerData = new TexturePackerData("assets/data/kyary.json", "assets/images/kyary.png");
		loadGraphicFromTexture(tex);
		var names:Array<String> = new Array<String>();
		for (i in 0...6)
			names.push("kyary_" + i + ".png");
		animation.addByNames("idle", names, 15);
		animation.play("idle");
		
		shotAnim = new FlxSprite(30, 18);
		tex = new TexturePackerData("assets/data/bulletParticle.json", "assets/images/bulletParticle.png");
		shotAnim.loadGraphicFromTexture(tex);
		names = new Array<String>();
		for (i in 0...6)
			names.push("bulletParticle_" + i + ".png");
		shotAnim.animation.addByNames("shoot", names, 15, false);
		shotAnim.visible = false;
		
		heart = new FlxSprite(8, 16, "assets/images/heart2.png");
		FlxTween.color(heart, TimeMaster.beatTime / 1000, 0xFFFFFF, 0xFFFFFF, 1, 0.4, { type: FlxTween.PINGPONG } );
		heart.visible = false;
		heart.width = 8;
		heart.height = 10;
		heart.offset.x = 1;
		heart.offset.y = 1;
		
		//loadGraphic("assets/images/kyaryzontal.png");
		
		//	Player hitbox and offset setting
		/*width = 16;
		height = 28;
		origin.x = -10;
		origin.y = -20;
		offset.x = 10;
		offset.y = 20;*/
		
		
		health = GC.playerLives;
		
		bulletGroup = new FlxTypedGroup<Bullet>();
	}
	
	override public function update():Void {
		super.update();
		
		if (canPlay)
		{
			shotAnim.x = x + 30 - shotAnim.width / 2;
			shotAnim.y = y + 18 - shotAnim.height / 2;
			if (shotAnim.animation.finished)
				shotAnim.visible = false;
			
			heart.x = x + 9;
			heart.y = y + 16;
			
			//	Movement input checking		
			updateMovement();		
			
			if (isFocused)
				heart.visible = true;
			else
				heart.visible = false;
			
			shoot();
		}
	}	
	
	private function shoot():Void {
		//	Shoot when Z is pressed AND the beat is on
		if (FlxG.keys.pressed.Z && TimeMaster.isBeat)
		{
			bulletGroup.add(new Bullet(x + 30, y + 18, "assets/images/shot-2big.png"));
			shootSFX.play();
			shotAnim.animation.play("shoot", true);
			shotAnim.visible = true;
		}
	}
	
	//	Movement input checking
	private function updateMovement():Void {		
		velocity.x = 0;
		velocity.y = 0;
		
		//	Left-right input
		if (FlxG.keys.pressed.LEFT && FlxG.keys.pressed.RIGHT)
			velocity.x = 0;
		else if (FlxG.keys.pressed.LEFT)
			velocity.x = -GC.playerSpeed;
		else if (FlxG.keys.pressed.RIGHT)
			velocity.x = GC.playerSpeed;
			
		//	Up-down input
		if (FlxG.keys.pressed.UP && FlxG.keys.pressed.DOWN)
			velocity.y = 0;
		else if (FlxG.keys.pressed.UP)
			velocity.y = -GC.playerSpeed;
		else if (FlxG.keys.pressed.DOWN)
			velocity.y = GC.playerSpeed;
		
		//	Hardcoded diagonal speed
		//  "Hardcoded" means "good"
		if (velocity.x != 0 && velocity.y != 0)
		{
			velocity.x *= 0.707;
			velocity.y *= 0.707;
		}
		
		//	Focus mode
		if (FlxG.keys.pressed.SHIFT)
		{
			isFocused = true;
			velocity.x *= 0.5;
			velocity.y *= 0.5;
		}
		else
			isFocused = false;
		
		//	OOB checking
		if (x < 0)
			x = 0;
		else if (x + width > FlxG.width)
			x = FlxG.width - width;
		if (y < 0)
			y = 0;
		else if (y + height > FlxG.height)
			y = FlxG.height - height;
	}
	
	public function get_bulletGroup():FlxTypedGroup<Bullet>	{
		return bulletGroup;
	}
	
	public function get_shotAnim():FlxSprite	{
		return shotAnim;
	}
	
	public function get_heart():FlxSprite	{
		return heart;
	}
	
	public function get_shootSFX():FlxSound	{
		return shootSFX;
	}
	
	public function get_hurtSFX():FlxSound	{
		return hurtSFX;
	}
	
}