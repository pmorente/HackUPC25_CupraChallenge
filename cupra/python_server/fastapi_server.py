from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import random
import os
import json
import google.generativeai as genai
from typing import Optional, List, Dict, Any
import uvicorn
import re
from pathlib import Path

# --- Game Configuration ---
MAX_CLUES = 3

# --- In-memory storage for game states ---
active_games = {}
next_game_id = 1

# --- FastAPI App Initialization ---
app = FastAPI(
    title="Guessing Game API",
    description="API for a concept guessing game powered by Gemini AI",
    version="1.0.0"
)

# Enable CORS with specific settings for mobile development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# --- Pydantic Models for Request/Response ---
class StartGameRequest(BaseModel):
    card_data: Dict[str, str]

class GuessRequest(BaseModel):
    game_id: str
    guess: str

class GameResponse(BaseModel):
    game_id: str
    clue: str
    feature_id: Optional[str] = None
    feature_type: Optional[str] = None
    attempts_remaining: int
    message: str

class GuessResponse(BaseModel):
    is_correct: bool
    message: str
    next_clue: Optional[str] = None
    attempts_remaining: int
    attempts_used: int
    previous_guesses: List[str]
    feature: Optional[dict] = None
    explanation: Optional[str] = None
    game_over: bool = False
    won: bool = False
    correct_concept: Optional[str] = None

# --- Gemini API Configuration ---
try:
    # Configure the Gemini API key directly
    API_KEY = ''
    genai.configure(api_key=API_KEY)
    # Create the model instance (e.g., 'gemini-1.5-flash' or 'gemini-pro')
    # Choose the model that best suits your needs and availability
    model = genai.GenerativeModel('gemini-1.5-flash')
    print("Gemini API configured successfully.")
except Exception as e:
    print(f"Error configuring Gemini API: {e}")
    # You might want to exit or handle this more gracefully depending on your application
    model = None # Ensure model is None if configuration fails

# --- Helper Functions ---
def parse_gemini_json_response(response_text: str) -> Optional[Dict]:
    """Parse the Gemini API response into a JSON object."""
    try:
        # Find the first { and last } in the response
        start = response_text.find('{')
        end = response_text.rfind('}') + 1
        if start == -1 or end == 0:
            return None
        json_str = response_text[start:end]
        return json.loads(json_str)
    except Exception as e:
        print(f"Error parsing Gemini response: {e}")
        return None

def get_initial_clue_from_gemini(card_data: Dict[str, Any]) -> Dict[str, Any]:
    if not model:
        return {"status": "error", "clue": None, "reasoning": "Gemini API not configured"}

    target_text = card_data.get('text', '')
    prompt = f"""
    You are a helpful assistant creating clues for a car feature guessing game.
    The target text is: "{target_text}"
    
    Generate a single, interesting, and not too obvious first clue for this car feature.
    The clue should:
    1. Hint at the feature's function or purpose
    2. Not directly mention the feature name
    3. Be relevant to the car's operation or safety
    
    Respond ONLY with a JSON object containing two keys:
    1. "status": set to "success".
    2. "clue": containing the generated clue string.

    Example for target text "Front passenger front airbag off ››› page 50":
    {{
      "status": "success",
      "clue": "This safety feature can be disabled for specific passenger situations."
    }}

    Now, generate the response for the target text: "{target_text}".
    """
    try:
        print(f"Asking Gemini for initial clue for: {target_text}")
        response = model.generate_content(prompt)
        parsed_response = parse_gemini_json_response(response.text)

        if parsed_response and "status" in parsed_response and "clue" in parsed_response:
            print(f"Gemini initial clue response: {parsed_response}")
            return parsed_response
        else:
            print(f"Gemini response (non-JSON or unexpected format): {response.text}")
            return {
                "status": "success",
                "clue": response.text.strip(),
                "reasoning": "Gemini response format was unexpected, using raw text."
            }

    except Exception as e:
        print(f"Error calling Gemini API (initial clue): {e}")
        return {"status": "error", "clue": None, "reasoning": str(e)}

def evaluate_guess_with_gemini(card_data: Dict[str, Any], guess: str, clues_given: List[str]) -> Dict[str, Any]:
    if not model:
        return {"status": "error", "clue": None, "reasoning": "Gemini API not configured"}

    target_text = card_data.get('text', '')
    clues_string = "\n".join([f"- {clue}" for clue in clues_given])

    prompt = f"""
    You are the judge in a car feature guessing game.
    The target text is: "{target_text}"
    The user has already received the following clues:
    {clues_string}

    The user's latest guess is: "{guess}".

    Analyze the guess. Is it correct or close enough to the target text "{target_text}"?

    Respond ONLY with a JSON object containing the following keys:
    1. "status": set to "correct" if the guess is correct, or "incorrect" if it is wrong.
    2. "clue": If the status is "incorrect", provide a *new*, helpful clue that hasn't been given before. If the status is "correct", set this to null.
    3. "reasoning": Explain in detail why the guess was incorrect, focusing on:
       - What aspects of the guess are not matching the target
       - Any correlations or similarities with other car parts that might be causing confusion
       - How the guess relates to a different part of the car
       - What aspects of the guess need to be more specific or different
       - DO NOT reveal the correct answer or give away too much information

    IMPORTANT: 
    - Only explain why the guess is wrong, never reveal the correct answer
    - Make the explanation educational and helpful for the user to think differently
    - Keep the explanation focused on the guess itself, not the answer

    Example for target text "Front passenger front airbag off ››› page 50", guess "airbag", status "incorrect":
    {{
      "status": "incorrect",
      "clue": "This feature can be toggled on or off depending on the passenger situation.",
      "reasoning": "Your guess of 'airbag' is too general. Modern cars have multiple airbags (driver, passenger, side, curtain), and each serves a specific purpose. Think about which specific airbag this feature might be referring to and what makes it unique."
    }}

    Example for target text "Front passenger front airbag off ››› page 50", guess "front passenger airbag off", status "correct":
     {{
      "status": "correct",
      "clue": null,
      "reasoning": "Your guess exactly matches the target text."
    }}

    Now, evaluate the guess "{guess}" for the target text "{target_text}" given the previous clues.
    """
    try:
        print(f"Asking Gemini to evaluate guess: '{guess}' for target text: '{target_text}'")
        response = model.generate_content(prompt)
        parsed_response = parse_gemini_json_response(response.text)

        if parsed_response and "status" in parsed_response and "clue" in parsed_response and "reasoning" in parsed_response:
            if parsed_response["status"] not in ["correct", "incorrect"]:
                print(f"Warning: Gemini returned unexpected status: {parsed_response['status']}")
                parsed_response["status"] = "incorrect"
                if parsed_response["clue"] is None:
                    parsed_response["clue"] = "The evaluation was unclear, but the guess seems incorrect. Try again."

            print(f"Gemini evaluation response: {parsed_response}")
            return parsed_response
        else:
            print(f"Gemini response (non-JSON or unexpected format): {response.text}")
            is_correct_in_text = "correct" in response.text.lower()
            return {
                "status": "correct" if is_correct_in_text else "incorrect",
                "clue": None if is_correct_in_text else response.text.strip(),
                "reasoning": "Gemini response format was unexpected."
            }

    except Exception as e:
        print(f"Error calling Gemini API (evaluate guess): {e}")
        return {"status": "error", "clue": None, "reasoning": str(e)}

def extract_options(text: str) -> List[Dict[str, str]]:
    """Extract numbered options from the text."""
    options = []
    # Split text into sections (numbered items and lettered sections)
    sections = re.split(r'([A-Z] [^A-Z]+)', text)
    
    for section in sections:
        if section.strip():
            # Handle numbered items
            if re.match(r'^\d+', section):
                parts = section.split(' ', 1)
                if len(parts) == 2:
                    options.append({
                        'number': parts[0],
                        'text': parts[1].strip()
                    })
            # Handle lettered sections
            elif re.match(r'^[A-Z] ', section):
                parts = section.split(' ', 1)
                if len(parts) == 2:
                    options.append({
                        'number': parts[0],
                        'text': parts[1].strip()
                    })
    
    return options

def select_random_option(options: List[Dict[str, str]]) -> Dict[str, str]:
    """Select a random option from the list."""
    return random.choice(options)

# --- API Endpoints ---
@app.post("/start_game", response_model=GameResponse)
async def start_game(request: StartGameRequest):
    """Start a new game with the provided card data."""
    try:
        # Validate card data
        card_data = request.card_data
        if not card_data or not isinstance(card_data, dict):
            raise HTTPException(status_code=400, detail="Invalid card data provided")
        
        # Get text and validate it
        text = card_data.get("text")
        if not text or not isinstance(text, str):
            raise HTTPException(status_code=400, detail="No valid text available in card data")
        
        # Select a random feature from the text
        selected_feature = select_random_feature(card_data)
        
        # Generate a new game ID
        global next_game_id
        game_id = str(next_game_id)
        next_game_id += 1
        
        # Create new game state
        game_state = {
            "game_id": game_id,
            "card_data": card_data,
            "selected_feature": selected_feature,
            "guesses": [],
            "is_completed": False,
            "attempts": 0,
            "max_attempts": 5,
            "clues_given": []
        }
        
        # Store game state
        active_games[game_id] = game_state
        
        # Generate initial clue
        initial_clue = get_initial_clue_from_gemini(card_data)
        if initial_clue["status"] == "error":
            raise HTTPException(status_code=500, detail="Failed to generate initial clue")
        
        # Add the clue to the game state
        game_state["clues_given"].append(initial_clue["clue"])
        
        return {
            "game_id": game_id,
            "clue": initial_clue["clue"],
            "attempts_remaining": game_state["max_attempts"],
            "message": "Game started successfully!"
        }
        
    except Exception as e:
        print(f"Error starting game: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/guess", response_model=GuessResponse)
async def handle_guess(guess_request: GuessRequest):
    """
    Submit a guess for a game and get feedback.
    """
    if not model:
        raise HTTPException(status_code=503, detail="Gemini API not configured, cannot process guess.")

    game_id = guess_request.game_id
    user_guess = guess_request.guess

    if game_id not in active_games:
        raise HTTPException(status_code=404, detail="Invalid game ID")

    game_state = active_games[game_id]

    if game_state['is_completed']:
        return {
            "is_correct": False,
            "message": "This game has already ended.",
            "next_clue": None,
            "attempts_remaining": 0,
            "attempts_used": game_state['attempts'],
            "previous_guesses": game_state['guesses'],
            "game_over": True,
            "won": False,
            "correct_concept": game_state['card_data'].get('text', '')
        }

    game_state['attempts'] += 1
    game_state['guesses'].append(user_guess)
    print(f"Game {game_id}: Attempt {game_state['attempts']}, Guess='{user_guess}'")

    if game_state['attempts'] >= game_state['max_attempts']:
        game_state['is_completed'] = True
        return {
            "is_correct": False,
            "message": f"Incorrect. You've run out of attempts! The feature was: {game_state['card_data'].get('text', '')}",
            "next_clue": None,
            "attempts_remaining": 0,
            "attempts_used": game_state['attempts'],
            "previous_guesses": game_state['guesses'],
            "game_over": True,
            "won": False,
            "correct_concept": game_state['card_data'].get('text', '')
        }

    # Get the target text from the card data
    target_text = game_state['card_data'].get('text', '')
    clues_string = "\n".join([f"- {clue}" for clue in game_state['clues_given']])

    # Generate next clue and evaluate guess
    prompt = f"""
    You are the judge in a car feature guessing game.
    The target text is: "{target_text}"
    The user has already received the following clues:
    {clues_string}

    The user's latest guess is: "{user_guess}".

    Analyze the guess. Is it correct or close enough to the target text "{target_text}"?

    Respond ONLY with a JSON object containing the following keys:
    1. "status": set to "correct" if the guess is correct, or "incorrect" if it is wrong.
    2. "clue": If the status is "incorrect", provide a *new*, helpful clue that hasn't been given before. If the status is "correct", set this to null.
    3. "reasoning": Explain in detail why the guess was incorrect, focusing on:
       - What aspects of the guess are not matching the target
       - Any correlations or similarities with other car parts that might be causing confusion
       - How the guess relates to a different part of the car
       - What aspects of the guess need to be more specific or different
       - DO NOT reveal the correct answer or give away too much information

    IMPORTANT: 
    - Only explain why the guess is wrong, never reveal the correct answer
    - Make the explanation educational and helpful for the user to think differently
    - Keep the explanation focused on the guess itself, not the answer

    Example for target text "Front passenger front airbag off ››› page 50", guess "airbag", status "incorrect":
    {{
      "status": "incorrect",
      "clue": "This feature can be toggled on or off depending on the passenger situation.",
      "reasoning": "Your guess of 'airbag' is too general. Modern cars have multiple airbags (driver, passenger, side, curtain), and each serves a specific purpose. Think about which specific airbag this feature might be referring to and what makes it unique."
    }}

    Example for target text "Front passenger front airbag off ››› page 50", guess "front passenger airbag off", status "correct":
     {{
      "status": "correct",
      "clue": null,
      "reasoning": "Your guess exactly matches the target text."
    }}

    Now, evaluate the guess "{user_guess}" for the target text "{target_text}" given the previous clues.
    """

    try:
        print(f"Asking Gemini to evaluate guess: '{user_guess}' for target text: '{target_text}'")
        response = model.generate_content(prompt)
        parsed_response = parse_gemini_json_response(response.text)

        if parsed_response and "status" in parsed_response and "clue" in parsed_response and "reasoning" in parsed_response:
            if parsed_response["status"] not in ["correct", "incorrect"]:
                print(f"Warning: Gemini returned unexpected status: {parsed_response['status']}")
                parsed_response["status"] = "incorrect"
                if parsed_response["clue"] is None:
                    parsed_response["clue"] = "The evaluation was unclear, but the guess seems incorrect. Try again."

            print(f"Gemini evaluation response: {parsed_response}")
            
            if parsed_response["status"] == "correct":
                game_state['is_completed'] = True
                return {
                    "is_correct": True,
                    "message": f"Congratulations! You guessed the feature: {target_text}",
                    "next_clue": None,
                    "attempts_remaining": game_state['max_attempts'] - game_state['attempts'],
                    "attempts_used": game_state['attempts'],
                    "previous_guesses": game_state['guesses'],
                    "game_over": True,
                    "won": True,
                    "correct_concept": target_text
                }

            elif parsed_response["status"] == "incorrect":
                next_clue = parsed_response.get("clue")
                if next_clue:
                    game_state['clues_given'].append(next_clue)
                else:
                    print(f"Warning: Gemini reported 'incorrect' but provided no clue for game {game_id}.")
                    next_clue = "That wasn't it. Try thinking from a different angle."

                return {
                    "is_correct": False,
                    "message": f"Incorrect. {parsed_response.get('reasoning', '')} Here's another clue:",
                    "next_clue": next_clue,
                    "attempts_remaining": game_state['max_attempts'] - game_state['attempts'],
                    "attempts_used": game_state['attempts'],
                    "previous_guesses": game_state['guesses'],
                    "game_over": False,
                    "won": False
                }

        else:
            print(f"Gemini response (non-JSON or unexpected format): {response.text}")
            return {
                "is_correct": False,
                "message": "Error evaluating guess. Please try again.",
                "next_clue": None,
                "attempts_remaining": game_state['max_attempts'] - game_state['attempts'],
                "attempts_used": game_state['attempts'],
                "previous_guesses": game_state['guesses'],
                "game_over": False,
                "won": False
            }

    except Exception as e:
        print(f"Error calling Gemini API (evaluate guess): {e}")
        return {
            "is_correct": False,
            "message": f"Error: {str(e)}",
            "next_clue": None,
            "attempts_remaining": game_state['max_attempts'] - game_state['attempts'],
            "attempts_used": game_state['attempts'],
            "previous_guesses": game_state['guesses'],
            "game_over": False,
            "won": False
        }

# Load metadata from JSON file
def load_metadata():
    """Load metadata from JSON file."""
    try:
        # Try to load from the lib directory first
        lib_path = Path(__file__).parent.parent / "lib" / "image_text_data" / "metadata.json"
        if lib_path.exists():
            with open(lib_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get('views', [])
        
        # Fallback to assets directory
        assets_path = Path(__file__).parent.parent / "assets" / "metadata.json"
        if assets_path.exists():
            with open(assets_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get('views', [])
        
        print("Error: metadata.json not found in either location")
        return []
    except Exception as e:
        print(f"Error loading metadata: {e}")
        return []

# Load metadata at startup
metadata = load_metadata()
if not metadata:
    print("Warning: No metadata loaded. The game will not work properly.")

metadata = load_metadata()

class GameState(BaseModel):
    game_id: str
    card_data: dict
    selected_feature: Optional[dict] = None
    guesses: List[str] = []
    is_completed: bool = False
    attempts: int = 0
    max_attempts: int = 5
    clues_given: List[str] = []

# Store active games
active_games: Dict[str, GameState] = {}

def get_card_by_title(title: str) -> Optional[dict]:
    """Find a card by its title in the metadata."""
    if not metadata:
        print("Warning: Metadata is empty")
        return None
        
    # First try exact match
    for card in metadata:
        if card.get("title") == title:
            return card
            
    # If no exact match, try case-insensitive match
    for card in metadata:
        if card.get("title", "").lower() == title.lower():
            return card
            
    # If still no match, try partial match
    for card in metadata:
        if title.lower() in card.get("title", "").lower():
            return card
            
    print(f"Warning: No card found with title '{title}' in metadata")
    return None

def select_random_feature(card_data: dict) -> dict:
    """Select a random feature or text from the card's data."""
    # Validate input
    if not isinstance(card_data, dict):
        raise ValueError("Card data must be a dictionary")
    
    # Get text and validate it
    text = card_data.get("text")
    if not text or not isinstance(text, str):
        raise ValueError("No valid text available in card data")
    
    # Split the text into feature and page reference
    text_parts = text.split("›››")
    if len(text_parts) < 1:
        raise ValueError("Invalid text format in card data")
    
    main_text = text_parts[0].strip()
    page_ref = text_parts[1].strip() if len(text_parts) > 1 else ""
    
    return {
        "id": "1",
        "type": "text",
        "name": main_text,
        "description": f"This feature is described on {page_ref}",
        "page": page_ref
    }

def generate_clue(feature: dict) -> str:
    """Generate a clue based on the text."""
    description = feature.get("description", "")
    return f"This feature {description}"

def generate_detailed_feedback(guess: str, feature: dict) -> tuple[str, str]:
    """Generate detailed feedback about why the guess was incorrect and a more specific clue."""
    feature_name = feature.get("name", "")
    description = feature.get("description", "")
    
    # Simple feedback based on the guess
    if guess in feature_name or feature_name in guess:
        feedback = "You're close! Think about the specific function of this feature."
        next_clue = f"This feature {description}"
    else:
        feedback = f"That's not it. This feature {description}"
        next_clue = f"This feature is specifically described on {feature.get('page', '')}"
    
    return feedback, next_clue

if __name__ == "__main__":
    # Get the local IP address
    import socket
    def get_local_ip():
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        try:
            # doesn't even have to be reachable
            s.connect(('10.255.255.255', 1))
            IP = s.getsockname()[0]
        except Exception:
            IP = '127.0.0.1'
        finally:
            s.close()
        return IP

    local_ip = get_local_ip()
    
    print(f"\nServer will be accessible at:")
    print(f"Local: http://localhost:5001")
    print(f"Network: http://{local_ip}:5001")
    print(f"API Documentation: http://{local_ip}:5001/docs")
    print("\nPress CTRL+C to quit\n")
    
    # Run the server
    uvicorn.run(app, host="0.0.0.0", port=5001) 
