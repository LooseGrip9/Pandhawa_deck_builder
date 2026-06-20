extends Node

#card related events
signal card_drag_started(card_ui: CardUI)
signal card_drag_ended(card_ui: CardUI)
signal card_aim_started(card_ui: CardUI)
signal card_aim_ended(card_ui: CardUI)
signal card_played(card: Card)
signal card_tooltip_requested(card: Card)
signal tooltip_hide_requested
signal card_added_to_deck(card: Card)
signal card_costs_updated

#player related events
signal player_hand_drawn
signal player_hand_discarded
signal player_turn_started
signal player_turn_ended
signal player_died
signal player_hit
signal energy_gain_requested(amount: int)

#Enemy related events
signal enemy_action_completed(enemy: Enemy)
signal enemy_turn_ended
signal enemy_died(enemy: Enemy)

#Battle related events
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
signal battle_won
signal battle_lose
signal status_tooltip_requested(statuses: Array[Status])

#map
signal map_exited(room: Room)

#shop
signal shop_exited
signal shop_relic_bought(relic: Relic, gold_cost: int)
signal shop_card_bought(card: Card, gold_cost: int)
signal shop_entered(shop: Shop)

#campfire
signal campfire_exited

#Battle reward
signal battle_reward_exited

#treasure
signal treasure_room_exited(found_relic: Relic)

#relic
signal relic_tooltip_requested(relic: Relic)

signal cutscene_finished 
signal room_exited
signal quiz_completed
