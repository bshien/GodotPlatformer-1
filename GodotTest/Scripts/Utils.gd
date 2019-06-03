static func moveTowards(current:float, target:float, maxDelta:float):
     if abs(target - current) <= maxDelta:
         return target
     return current + sign(target - current) * maxDelta
	
static func jumpGravity(jumpHeight:float,jumpTime:float):
	return 2*jumpHeight/(jumpTime*jumpTime)

static func jumpVeloctiy(gravity: float, jumpTime:float):
	return -gravity*jumpTime