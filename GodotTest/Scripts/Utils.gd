static func moveTowards(current:float, target:float, maxDelta:float):
     if abs(target - current) <= maxDelta:
         return target
     return current + sign(target - current) * maxDelta