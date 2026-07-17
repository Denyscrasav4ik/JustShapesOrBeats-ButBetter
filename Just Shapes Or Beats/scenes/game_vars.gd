extends Node


enum {
    MODE_PARTY,
    MODE_NORMAL,
    MODE_HARDCORE,
}
enum {
    RANK_S,
    RANK_A,
    RANK_B,
    RANK_C,
}


@onready var STRUCT_LIST = preload("res://resources/level_structs/level_struct_list.tres").struct_list

@onready var STRUCT_UID = preload("res://resources/level_structs/level_struct_list.tres").struct_uid


var current_struct: LevelStruct = preload("res://resources/level_structs/songs/terabyte_connection.tres")
var current_mode: int = 1
var menu_target_ctrl: int = 0


var best_ranks: Dictionary = {}


func _ready():
    load_ranks()


func load_ranks():
    if not FileAccess.file_exists("user://ranks.save"):
        return

    var file = FileAccess.open("user://ranks.save", FileAccess.READ)
    if file:
        var test_json_conv = JSON.new()
        var parse_err = test_json_conv.parse(file.get_as_text())
        if parse_err == OK:
            best_ranks = test_json_conv.get_data()
        file.close()


func save_ranks():
    var file = FileAccess.open("user://ranks.save", FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(best_ranks))
        file.close()


func get_menu_target_ctrl() -> int:
    var value = menu_target_ctrl
    menu_target_ctrl = 0
    return value


func add_rank(rank: int):
    if current_mode == MODE_PARTY: return

    var struct: LevelStruct = current_struct
    if struct.is_hardcore:
        struct = load(current_struct.other_variant)
        assert (struct, "Could not find normal variant of level struct.")
        assert ( not struct.is_hardcore,
                "Searched for the normal version of level struct, but it is not normal."
        )


    var id: String = STRUCT_UID[STRUCT_LIST.find(struct)]
    if not id in best_ranks:
        best_ranks[id] = [ - 1, - 1]

    var index: int = 1 if current_mode == MODE_HARDCORE else 0

    if best_ranks[id][index] != - 1:
        if best_ranks[id][index] <= rank:
            return

    best_ranks[id][index] = rank

    save_ranks()


func get_ranks(struct: LevelStruct) -> Array:
    var id: String = STRUCT_UID[STRUCT_LIST.find(struct)]
    return [ - 1, - 1] if not id in best_ranks else best_ranks[id]
