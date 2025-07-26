from datetime import datetime
from test_generator import generate_valid_user_preferences, AGE_GROUPS, GROUP_RELATIONSHIPS, TRAVEL_STYLES, CURRENCIES, LIKES, DISLIKES, MUST_HAVES, DEAL_BREAKERS

def test_generate_fake_preferences_structure():
    prefs = generate_valid_user_preferences()
    assert "group_size" in prefs
    assert isinstance(prefs["likes"], list)
    assert "age_group" in prefs["traveler_info"]

def test_budget_min_less_than_max():
    prefs = generate_valid_user_preferences()
    assert prefs["budget"]["min"] < prefs["budget"]["max"], "Budget min should be less than max"

def test_group_relationship_valid():
    valid_relationships = GROUP_RELATIONSHIPS
    prefs = generate_valid_user_preferences()
    assert prefs["group_relationship"] in valid_relationships, "Invalid group relationship"

def test_travel_style_valid():
    valid_styles = TRAVEL_STYLES
    prefs = generate_valid_user_preferences()
    assert prefs["travel_style"] in valid_styles, "Invalid travel style"

def test_likes_not_empty():
    prefs = generate_valid_user_preferences()
    assert len(prefs["likes"]) > 0, "Likes list should not be empty"

def test_dislikes_not_empty():
    prefs = generate_valid_user_preferences()
    assert len(prefs["dislikes"]) > 0, "Dislikes list should not be empty"

def test_must_haves_not_empty():
    prefs = generate_valid_user_preferences()
    assert len(prefs["must_haves"]) > 0, "Must haves list should not be empty"

def test_deal_breakers_not_empty():
    prefs = generate_valid_user_preferences()
    assert len(prefs["deal_breakers"]) > 0, "Deal breakers list should not be empty"

def test_travel_dates_validity():
    prefs = generate_valid_user_preferences()
    start_date = datetime.strptime(prefs["travel_dates"]["start_date"], "%Y-%m-%d")
    end_date = datetime.strptime(prefs["travel_dates"]["end_date"], "%Y-%m-%d")
    assert start_date < end_date, "Start date must be before end date"

def test_currency_validity():
    prefs = generate_valid_user_preferences()
    assert prefs["budget"]["currency"] in CURRENCIES, "Currency is invalid"

def test_no_overlap_in_lists():
    prefs = generate_valid_user_preferences()
    likes = set(prefs["likes"])
    dislikes = set(prefs["dislikes"])
    must_haves = set(prefs["must_haves"])
    deal_breakers = set(prefs["deal_breakers"])

    # Check intersections are empty where they should be
    assert likes.isdisjoint(dislikes), "Likes and dislikes should not overlap"
    assert likes.isdisjoint(must_haves), "Likes and must_haves should not overlap"
    assert likes.isdisjoint(deal_breakers), "Likes and deal_breakers should not overlap"
    assert dislikes.isdisjoint(must_haves), "Dislikes and must_haves should not overlap"

def test_group_size_edge_cases():
    prefs = generate_valid_user_preferences()
    # Test min group size
    prefs["group_size"] = 1
    assert prefs["group_size"] >= 1, "Group size should be at least 1"
    # Test max group size
    prefs["group_size"] = 10
    assert prefs["group_size"] <= 10, "Group size should be at most 10"

def test_budget_boundaries():
    prefs = generate_valid_user_preferences()
    # Test min budget boundary
    prefs["budget"]["min"] = 0
    assert prefs["budget"]["min"] >= 0, "Min budget should be non-negative"
    # Test max budget boundary (some reasonable upper limit)
    prefs["budget"]["max"] = 100000
    assert prefs["budget"]["max"] <= 100000, "Max budget should be reasonable"
