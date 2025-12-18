# Onassis Timeline

A Rails 8 application for researching and documenting the life of Aristotle Onassis. This is a personal research tool that organizes biographical events, people, sources, and newspaper articles into an interconnected timeline.

## Purpose

This app serves as a research companion for building a comprehensive timeline of Aristotle Onassis's life. It allows you to:

- Record historical events with dates, locations, and descriptions
- Track people (characters) involved in his life and their relationships
- Cite sources (books, documentaries, archives) for verification
- Link newspaper articles that may relate to multiple events and people
- Store historical images in a gallery, linked to events and people
- Search and filter the timeline by date, event type, or person

## Tech Stack

- **Framework:** Rails 8.0.4
- **Database:** SQLite3
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Assets:** Propshaft + ImportMap (no Node.js build step)
- **CSS:** Custom stylesheet (no framework)
- **File Storage:** Active Storage (local disk)

## Data Model

### Core Entities

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Entry     │     │  Character  │     │   Source    │     │   Article   │     │   Image     │
│  (events)   │     │  (people)   │     │  (books,    │     │ (newspaper  │     │  (photos)   │
│             │     │             │     │   docs)     │     │  articles)  │     │             │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### Relationships

```
Entry ←──────→ Character     (many-to-many via EntryCharacter)
Entry ←──────→ Source        (many-to-many via EntrySource)
Entry ←──────→ Article       (many-to-many via EntryArticle)
Entry ←──────→ Image         (many-to-many via EntryImage)
Character ←──→ Article       (many-to-many via ArticleCharacter)
Character ←──→ Image         (many-to-many via ImageCharacter)
Source ───────→ SourceLink   (one-to-many)
Character ────→ CharacterLink (one-to-many)
```

### Entry (Timeline Events)

The central model representing historical events.

| Field | Type | Description |
|-------|------|-------------|
| title | string | Event title (required) |
| event_date | date | When it happened (required) |
| end_date | date | For events spanning multiple days |
| location | string | Where it happened |
| entry_type | string | Category (see types below) |
| description | text | Detailed description |
| significance | text | Historical importance |
| verified | boolean | Whether sources confirm this |

**Entry Types:** birth, death, marriage, divorce, business, deal, acquisition, political, travel, scandal, meeting, speech, party, other

### Character (People)

People connected to Onassis's life.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Full name (required) |
| birth_date | date | Date of birth |
| death_date | date | Date of death |
| relationship | string | Relationship to Onassis |
| nationality | string | Country of origin |
| occupation | string | Profession |
| bio | text | Biography |
| lead_character | boolean | Mark as primary figure |

**Relationship Types:** family, business, romantic, political, social, rival, employee, other

**Helper Methods:**
- `lifespan` - Returns "1906-1975" format
- `age_at(date)` - Calculates age at a specific date (shown on timeline)

### Source (Research Materials)

Books, documentaries, and other research sources.

| Field | Type | Description |
|-------|------|-------------|
| title | string | Source title (required) |
| author | string | Author name |
| source_type | string | Type of source |
| publication_date | date | When published |
| publisher | string | Publisher name |
| notes | text | Research notes |

**Source Types:** book, newspaper, magazine, documentary, interview, archive, website, other

**Associated:** Can have multiple `SourceLink` records for external URLs.

### Article (Newspaper Articles)

Newspaper articles that can relate to multiple entries and characters.

| Field | Type | Description |
|-------|------|-------------|
| title | string | Article headline (required) |
| url | string | Link to article (required) |
| publication | string | Newspaper name |
| author | string | Journalist name |
| publication_date | date | When published |
| notes | text | Summary or key quotes |

**Key Feature:** Articles have many-to-many relationships with both Entries and Characters, allowing a single article to be linked to multiple events and people.

### Image (Historical Photos)

Photos stored with Active Storage, linked to entries and characters.

| Field | Type | Description |
|-------|------|-------------|
| title | string | Caption/description (optional) |
| file | attachment | Image file via Active Storage (required) |
| taken_date | date | When the photo was taken |
| location | string | Where it was taken |
| notes | text | Context or source info |
| source_url | string | Original URL if imported from web |

**Key Features:**
- Images are displayed in a chronological gallery (by `taken_date`) and can be linked to multiple entries and characters
- Gallery supports filtering by decade and character
- **URL Import:** Images can be imported directly from a URL without downloading first - paste a direct image link and it will be fetched and stored locally

### Junction Tables

| Table | Purpose |
|-------|---------|
| EntryCharacter | Links entries to characters, with optional `role` field |
| EntrySource | Links entries to sources, with `page_reference`, `author`, `link`, `notes` |
| EntryArticle | Links entries to articles |
| EntryImage | Links entries to images |
| ArticleCharacter | Links articles to characters |
| ImageCharacter | Links images to characters |
| SourceLink | External URLs for a source |
| CharacterLink | External URLs for a character (Wikipedia, etc.) |

## Routes & Navigation

| Path | Description |
|------|-------------|
| `/` | Timeline view (chronological entries) |
| `/entries` | All entries list |
| `/characters` | All people |
| `/sources` | All research sources |
| `/articles` | All newspaper articles |
| `/images` | Image gallery |
| `/search` | Search across all content |
| `/help` | Usage documentation |

## Key Features

### Timeline View
- Displays entries chronologically
- Shows character tags with ages at time of event
- Filter by decade, year, event type

### Character Ages
- When viewing an entry, character badges show their age at the time of the event
- Calculated from birth_date using `character.age_at(entry.event_date)`

### Multi-Source Citations
- Entries can cite multiple sources via EntrySource
- Each citation can include page references, specific authors (for edited volumes), notes, and direct links

### Related Articles Section
- Entry and Character show pages display related newspaper articles
- Articles can span multiple events and involve multiple people

### Image Gallery
- Chronological gallery view ordered by `taken_date`
- Filter by decade or character
- Images display on Entry and Character show pages
- Supports JPG, PNG, GIF, WebP formats
- Thumbnails auto-generated via Active Storage variants
- **Import from URL:** Add images directly from web URLs without downloading them first - the app fetches and stores them locally, preserving the original source URL for reference

## Running the App

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start server
bin/rails server
```

Visit `http://localhost:3000`

## File Structure

```
app/
├── controllers/
│   ├── entries_controller.rb
│   ├── characters_controller.rb
│   ├── sources_controller.rb
│   ├── articles_controller.rb
│   ├── images_controller.rb
│   ├── timeline_controller.rb
│   └── search_controller.rb
├── models/
│   ├── entry.rb
│   ├── character.rb
│   ├── source.rb
│   ├── article.rb
│   ├── image.rb
│   ├── entry_character.rb
│   ├── entry_source.rb
│   ├── entry_article.rb
│   ├── entry_image.rb
│   ├── article_character.rb
│   ├── image_character.rb
│   ├── source_link.rb
│   └── character_link.rb
├── views/
│   ├── entries/
│   ├── characters/
│   ├── sources/
│   ├── articles/
│   ├── images/
│   ├── timeline/
│   └── layouts/
└── assets/
    └── stylesheets/
        ├── application.css
        └── color_palette.css
```

## Design Patterns Used

### Nested Attributes
Sources, Characters, and their links use `accepts_nested_attributes_for` for inline editing of associated records in forms.

### Scopes
Models define scopes for common queries:
- `Entry.chronological`, `Entry.by_type(type)`, `Entry.by_decade(decade)`
- `Character.by_name`, `Character.lead`, `Character.family`
- `Source.books`, `Source.articles`
- `Article.by_date`, `Article.by_title`
- `Image.by_date`, `Image.by_date_desc`, `Image.recent_first`

### Dependent Destroy
All associations use `dependent: :destroy` to clean up join records when parent records are deleted.

## Notes for AI Assistants

When helping with this codebase:

1. **This is a research tool** - The focus is on organizing biographical data with proper source citations
2. **SQLite database** - Date queries use `strftime` syntax
3. **No authentication** - This is a personal/local tool
4. **Hotwire/Turbo** - Forms use Turbo for submissions, some views may use Turbo Streams
5. **Custom CSS** - Uses CSS custom properties defined in `color_palette.css` and `application.css`
6. **Many-to-many relationships** - Most entities connect through junction tables with additional metadata fields
7. **Active Storage** - Images use Active Storage with local disk storage; variants are used for thumbnails
