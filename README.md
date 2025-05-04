## Inspiration
We wanted to turn the traditionally dry vehicle manual into something customers actually look forward to using. Inspired by mobile trivia games like *Clash Royale* or *Wii Olympic Games 2012* and AI chat experiences, we created a playful way for customers to learn about their new CUPRA through an engaging AI-based guessing game — all while collecting exclusive digital CUPRA stickers.

## What it does
An AI-powered guesser system engine that, having the dataset of the manual, lets users choose a topic and start getting clues from the AI. The user has 5 tries to answer correctly. If the user answers wrong, the AI explains why it is wrong and gives a more specific clue each time. This helps customers get to know their car before delivery.

### Key features:
- A sticker collection system, where users earn exclusive CUPRA-themed digital stickers for correct answers and progress
- Daily challenges to maintain engagement
- Real-time feedback and explanations to help users learn key features  
  *(e.g., "Which CUPRA driving mode optimizes performance?")*

## How we built it
- **Flutter** was used for the cross-platform mobile app, ensuring sleek UI/UX for both iOS and Android.
- The **AI quiz logic** was built using Python, leveraging **LLM + RAG + Structured Outputs** to dynamically generate and evaluate questions.
- Stickers were designed to match CUPRA’s branding (colors, icons, cars) and include animations and fun facts *(Made with DALL·E)*.

## Challenges we ran into
- Ensuring the game remains fun while still being informative — striking the right balance was key.
- Designing exclusive sticker artwork that felt premium and brand-consistent.

## Accomplishments that we're proud of
- Created an AI-driven experience that feels dynamic and personalized to each CUPRA customer.
- Built a fully working prototype in Flutter + Python with a functioning backend and sticker reward system.
- Designed a gamified system that could potentially be integrated into CUPRA’s real app ecosystem.

## What we learned
- Gamification — when tied to real-world excitement like getting a new car — creates natural user engagement.
- Users are more likely to retain technical info when it’s presented in a quiz or challenge format.
- Flutter and Python worked well together, allowing us to separate the AI engine from the user interface cleanly.

## What's next for *Know Your CUPRA*
- Expand the sticker system with limited editions, vehicle milestones, and unlockable vehicle facts.
- Integrate AR features where users scan real objects (like keys or car brochures) to unlock sticker packs.
- Test with real CUPRA users and gather feedback to improve quiz content and engagement loops.
- Explore official collaboration with CUPRA to bring the interactive guesser into their delivery and onboarding workflow.
