class_name LevelStruct
extends Resource



@export var song: AudioStream
@export var song_name: String
@export var song_artist: String
@export var song_is_remix: bool
@export var song_playlist: String
@export var song_cover: Texture2D

@export var playback_pos: float
@export var key_list: Array # (Array, Resource)
@export var checkpoints: Array # (Array, float)
@export var hazard_group_list: Array # (Array, Resource)
@export var is_hardcore: bool



@export var other_variant: String
