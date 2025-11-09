extends Camera2D

# Call this when the player enters a room
# func set_room_limits(area: Area2D):
#     var shape = area.get_node("CollisionShape2D").shape
#     if shape is RectangleShape2D:
#         var rect = Rect2(area.global_position - shape.extents, shape.extents * 2)
#         limit_left = rect.position.x
#         limit_top = rect.position.y
#         limit_right = rect.position.x + rect.size.x
#         limit_bottom = rect.position.y + rect.size.y
