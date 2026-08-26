class_name GameConstants
extends Node

enum Characters
{
	NONE = -1,
	DUMMY = 0,
	ROHAN = 1,
	SKELETON = 2,
	WARRIOR = 3,
	JOE_HOOPS = 4
}

enum AttackTypes
{
	NONE = -1,
	PROJECTILE = 0,
	MELEE = 1
}

enum Attacks
{
	NONE = -1,
	KNIFE = 0
}

# Save system.
const SAVE_VERSION : int = 1
const SAVE_EXTENSION : String = ".dat"
