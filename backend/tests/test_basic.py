from test_generator import generate_fake_user_preferences

def test_generate_fake_preferences_structure():
    prefs = generate_fake_user_preferences()
    assert "group_size" in prefs
    assert isinstance(prefs["likes"], list)
    assert "age_group" in prefs["traveler_info"]

def test_budget_min_less_than_max():
    prefs = generate_fake_user_preferences()
    assert prefs["budget"]["min"] < prefs["budget"]["max"], "Budget min should be less than max"

def test_group_relationship_valid():
    valid_relationships = ["solo", "couple", "family", "friends"]
    prefs = generate_fake_user_preferences()
    assert prefs["group_relationship"] in valid_relationships, "Invalid group relationship"

def test_travel_style_valid():
    valid_styles = ["relaxed", "adventurous", "balanced"]
    prefs = generate_fake_user_preferences()
    assert prefs["travel_style"] in valid_styles, "Invalid travel style"

def test_likes_not_empty():
    prefs = generate_fake_user_preferences()
    assert len(prefs["likes"]) > 0, "Likes list should not be empty"

def test_dislikes_not_empty():
    prefs = generate_fake_user_preferences()
    assert len(prefs["dislikes"]) > 0, "Dislikes list should not be empty"

def test_must_haves_not_empty():
    prefs = generate_fake_user_preferences()
    assert len(prefs["must_haves"]) > 0, "Must haves list should not be empty"

def test_deal_breakers_not_empty():
    prefs = generate_fake_user_preferences()
    assert len(prefs["deal_breakers"]) > 0, "Deal breakers list should not be empty"
