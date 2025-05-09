class_name ShipAI

extends Ship

# Use manager to scatter enemies around player targets? Give them a target position, move them around intermittently?

# Movement functions:
    # Collision avoidance - use a manager to detect objects (including player) that are on a collision course and divert
    # Position around target - intermittently choose a position in 180deg range of target. Allow to drift. Use a manager?
    # Move towards target - move from far away
    # Passively follow the movement of the target - e.g. if player rotates, rotate around to dodge return fire

# Simple behaviour, no self-preservation besides collision avoidance
# Some ships might seek collisions?