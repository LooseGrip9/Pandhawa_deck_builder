class_name CouponRelic
extends Relic

@export_range(1, 100) var discount := 20

var relic_ui: RelicUI

func initialize_relic(_owner: RelicUI) -> void:
	Events.shop_entered.connect(add_shop_modifier)
	relic_ui = _owner

func deactivate_relic(_owner: RelicUI) -> void:
	Events.shop_entered.disconnect(add_shop_modifier)

func add_shop_modifier(shop: Shop) -> void:
	relic_ui.flash()
	
	var shop_cost_modifier := shop.modifier_handler.get_modifier(Modifier.Type.SHOP_COST)
	assert(shop_cost_modifier, "No shop modifier in shop!")
	
	var coupons_modifier_vallue := shop_cost_modifier.get_value("coupon")
	
	if not coupons_modifier_vallue:
		coupons_modifier_vallue = ModifierValue.create_new_modifier("coupon", ModifierValue.Type.PERCENT_BASED)
		coupons_modifier_vallue.percent_value = -1 * discount / 100.0
		shop_cost_modifier.add_new_value(coupons_modifier_vallue)
