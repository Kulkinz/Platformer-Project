/// @description Movement code

// Direction Code
// General movement direction taking right - left, -1 for left, 1 for right, 0 for both.
obj_settings.moveDirection = keyboard_check(vk_right) - keyboard_check(vk_left); 

/*
 * Movement Code
 *
 * If only one button is pressed, then it sets the sprite to marioMoving, and which direction with image_xscale.
 * Then if the side Mario is going to move in isn't colliding with obj_ground, it will add 5 in the direction intended to x.
 * If no buttons or both buttons are pressed, it will just set the sprite to a default one.
*/
if obj_settings.moveDirection != 0 {
	if !collision_point(obj_mario.x+(9*obj_settings.moveDirection), obj_mario.y, obj_ground, false, false) &&
	!collision_point(obj_mario.x+(9*obj_settings.moveDirection), obj_mario.y-32, obj_ground, false, false) {
		obj_mario.x += 5 * obj_settings.moveDirection;
	}
	sprite_index = spr_marioMoving;
	image_xscale = obj_settings.moveDirection;
} else {
	sprite_index = spr_mario;
}

if keyboard_check_pressed(vk_space) && obj_settings.jumpTotal < 3 && !obj_settings.hasJumped {
	obj_settings.jumpModifier += 0.5;
	obj_settings.jumpTotal += 1;
	obj_settings.hasJumped = true;
}

/*
 * Jump Code
 *
 * When the space button is pressed, Mario must jump. So when that happens, the currentJumpLength is added to by grav
 * Then the sprite is changed to spr_marioJump and hasPressed becomes true. Then it detects if there is any obj_ground
 * object over mario, and if there is, sets hasCollided to true. If it hasn't collided, then Mario's Y is just modified
 * by the jumpSpeed value. Else if it has collided and something is overhead, a value called currentFallLength gets
 * added to by grav, and the y value is manipulated by this. Duing all of this, if jumpSpeed is less than 0, the
 * sprite becomes spr_marioDescent.
 * If space is not being held and hasReleased is true, then it will try to figure out if it should continue momentum
 * or restart it. If Mario is still going up (jumpSpeed > 0) then it will use a new value for descent, which behaves
 * similarly for going up, except it is just plain going down. If Mario is already going down (jumpSpeed <= 0) then
 * it will just use the previous values, and use them for descent.
*/

if keyboard_check_pressed(vk_space) {
	obj_settings.hasPressed = true;
}

if obj_settings.hasPressed {
	obj_settings.currentJumpLength += obj_settings.grav; 
	obj_settings.jumpSpeed = (10*1)-obj_settings.currentJumpLength+(obj_settings.grav/2);
	sprite_index = spr_marioJump;
	if collision_point(obj_mario.x, obj_mario.y-33, obj_ground, true, false) { 
		obj_settings.hasCollided = true;
	}
	if !obj_settings.hasCollided { 
		obj_mario.y -= obj_settings.jumpSpeed; 
	} else {
		obj_settings.currentFallLength += obj_settings.grav;
		obj_mario.y += obj_settings.currentFallLength;
	}
	if obj_settings.jumpSpeed < 0 { sprite_index = spr_marioDescent }
}
/*} else if (obj_settings.hasReleased && obj_settings.jumpSpeed > 0) {
	obj_settings.currentFallLength += obj_settings.grav;
	obj_mario.y += obj_settings.currentFallLength;
	sprite_index = spr_marioDescent;
} else if (obj_settings.hasReleased && obj_settings.jumpSpeed <= 0) {
	obj_settings.currentJumpLength += obj_settings.grav;
	obj_settings.jumpSpeed = 10-obj_settings.currentJumpLength+(obj_settings.grav/2);
	obj_mario.y -= obj_settings.jumpSpeed;
	sprite_index = spr_marioDescent;
}*/

// When the space button is released, will set a variable to hasReleased;
if keyboard_check_released(vk_space) { obj_settings.hasReleased = true } 

/*
 * Landing Code
 *
 * If the point collides with obj_ground, then Mario's Y is raised to the average of currentFallLength and
 * currentJumpLength so that he will be over the ground instantly instead of being slowly raising, then
 * all values are set to default so they can be reused.
*/
if collision_point(obj_mario.x, obj_mario.y, obj_ground, true, false) {
	obj_mario.y -= obj_settings.currentJumpLength/2;
	obj_settings.currentJumpLength = 0;
	obj_settings.currentFallLength = 0;
	obj_settings.hasReleased = false;
	obj_settings.hasPressed = false;
	obj_settings.hasCollided = false;
	obj_settings.jumpSpeed = 0;
	obj_settings.hasJumped = false;
}

if collision_point(obj_mario.x, obj_mario.y+3, obj_ground, true, false) {
	obj_settings.currentGroundLength += 0.1;
}

if obj_settings.currentGroundLength > 4 {
	obj_settings.jumpModifier = 1;
	obj_settings.jumpTotal = 0;
}

/*
 * Gravity Code (Non Jumping)
 *
 * If the point doesn't collide with obj_ground, meaning it's above the ground, and hasReleased and
 * hasPressed is false, meaning this isn't because of an intended jump, then the currentFallLength
 * is added to for every frame it isnt on the ground, then Mario's Y is added to, and the sprite is
 * changed to spr_marioDescent.
*/
if !collision_point(obj_mario.x, obj_mario.y+2, obj_ground, true, false) && !obj_settings.hasPressed { 
	obj_settings.currentFallLength += obj_settings.grav; 
	obj_mario.y += obj_settings.currentFallLength; 
	sprite_index = spr_marioDescent;
}