# Onassis Timeline

A Rails 8 application for researching and documenting the life of Aristotle Onassis. This is a personal research tool that organizes biographical events, people, sources, newspaper articles, images, assets, and locations into an interconnected timeline.

## Purpose

This app serves as a research companion for building a comprehensive timeline of Aristotle Onassis's life. It allows you to:

- Record historical events with dates, locations, and descriptions
- Track people (characters) involved in his life and their relationships
- Cite sources (books, documentaries, archives) for verification
- Link newspaper articles that may relate to multiple events and people
- Store historical images in a gallery, linked to events and people
- Track significant assets (yachts, aircraft, residences, vehicles)
- Document filming locations for production research
- Search and filter the timeline by date, event type, or person

## Tech Stack

- **Framework:** Rails 8.0.4
- **Database:** SQLite3
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Assets:** Propshaft + ImportMap (no Node.js build step)
- **CSS:** Custom stylesheet (no framework)
- **File Storage:** Active Storage (local disk)

## Key Features

### Interactive Timeline
- Chronological display of entries, assets, and images
- Filter by decade, event type, or character
- Character badges show ages at time of event
- Clickable image thumbnails with lightbox preview
- Assets with acquisition dates appear automatically on timeline
- **Undated Images Section:** Images without dates appear in a separate grid below the timeline

### Date Precision
All date fields support flexible precision levels for when exact dates are unknown:
- **Exact date** - Full date display (e.g., "October 20, 1968")
- **Month only** - Month and year (e.g., "October 1968")
- **Year only** - Just the year (e.g., "1968")
- **Decade only** - Decade format (e.g., "1960s")
- **Approximate** - With "circa" prefix (e.g., "c. 1968")

### Image Gallery
- Chronological gallery ordered by `taken_date`
- Filter by decade or character
- **Import from URL:** Add images directly from web URLs - the app fetches and stores them locally
- **Source Attribution:** Track article URL, article title, author, website name, and website URL for each image
- Thumbnails auto-generated via Active Storage variants
- Supports JPG, PNG, GIF, WebP formats

### Production Assets
- Track significant objects: yachts, aircraft, vehicles, residences, jewelry, artwork
- **Visual Gallery Picker:** Select images from a visual grid modal
- **Featured Image:** Choose which image appears as the card thumbnail
- **Reference Links:** Link to auction pages, museum records, Wikipedia articles
- Assets with acquisition dates appear automatically on the timeline
- Production notes field for filming research

### Multi-Source Citations
- Entries can cite multiple sources via EntrySource
- Each citation can include page references, specific authors, notes, and direct links
- Sources have external links for online references

### Character Management
- Track birth/death dates with automatic age calculation
- **Lead Characters:** Mark primary figures who auto-attach to new entries
- External links (Wikipedia, IMDB, etc.)
- Relationship types: family, business, romantic, political, social, rival, employee

### Filming Locations
- Flexible geographic hierarchy: continent → country → region → city → neighborhood → address → building → room
- Special types for vessels and aircraft (for scenes aboard ships/planes)
- Link to timeline entries and images
- Production notes for filming permits, current condition, alternatives

## Data Model

### Core Entities

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Entry     │     │  Character  │     │   Source    │     │   Article   │
│  (events)   │     │  (people)   │     │  (books,    │     │ (newspaper  │
│             │     │             │     │   docs)     │     │  articles)  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘

┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Image     │     │   Asset     │     │  Location   │
│  (photos)   │     │  (props)    │     │  (filming)  │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Relationships

```
Entry ←──────→ Character     (many-to-many via EntryCharacter)
Entry ←──────→ Source        (many-to-many via EntrySource)
Entry ←──────→ Article       (many-to-many via EntryArticle)
Entry ←──────→ Image         (many-to-many via EntryImage)
Entry ←──────→ Asset         (many-to-many via EntryAsset)
Entry ←──────→ Location      (many-to-many via EntryLocation)
Character ←──→ Article       (many-to-many via ArticleCharacter)
Character ←──→ Image         (many-to-many via ImageCharacter)
Asset ←──────→ Image         (many-to-many via AssetImage)
Location ←───→ Image         (many-to-many via ImageLocation)
Asset ────────→ Image        (featured_image - belongs_to)
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
| date_precision | string | How precise the date is (exact/month/year/decade/approximate) |
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
| lead_character | boolean | Mark as primary figure (auto-added to new entries) |

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

### Image (Historical Photos)

Photos stored with Active Storage, linked to entries and characters.

| Field | Type | Description |
|-------|------|-------------|
| title | string | Caption/description (optional) |
| file | attachment | Image file via Active Storage (required) |
| taken_date | date | When the photo was taken |
| taken_date_precision | string | Date precision (exact/month/year/decade/approximate) |
| location | string | Where it was taken |
| notes | text | Context or source info |
| source_url | string | Original URL if imported from web |
| article_url | string | URL of article where image was found |
| article_title | string | Title of the source article |
| article_author | string | Author of the source article |
| website_name | string | Name of the publication/website |
| website_url | string | Base URL of the website (auto-extracted) |

### Asset (Production Assets)

Significant objects relevant to production research.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Asset name (required) |
| asset_type | string | Category (see types below) |
| description | text | Historical details |
| acquisition_date | date | When acquired (appears on timeline) |
| acquisition_date_precision | string | Date precision |
| disposition_date | string | When/how disposed of |
| manufacturer | string | Who made it |
| notes | text | Production research notes |
| reference_url | string | Link to auction page, museum record, etc. |
| reference_title | string | Title for the reference link |
| featured_image_id | integer | Which image to show on card |

**Asset Types:** vehicle, vessel, aircraft, residence, building, jewelry, artwork, document, other

### Location (Filming Locations)

Filming locations with flexible geographic hierarchy.

| Field | Type | Description |
|-------|------|-------------|
| name | string | Location name (required) |
| location_type | string | Category (see types below) |
| continent | string | Continent |
| country | string | Country |
| region | string | Region or state |
| city | string | City |
| neighborhood | string | Neighborhood or district |
| address | string | Street address |
| building | string | Building name |
| room | string | Specific room or space |
| description | text | Historical details |
| notes | text | Production research notes |

**Location Types:** aircraft, airport, building, city, continent, country, embassy, estate, harbor, hospital, hotel, island, neighborhood, office, port, region, residence, restaurant, room, vessel, villa

### Junction Tables

| Table | Purpose |
|-------|---------|
| EntryCharacter | Links entries to characters, with optional `role` field |
| EntrySource | Links entries to sources, with `page_reference`, `author`, `link`, `notes` |
| EntryArticle | Links entries to articles |
| EntryImage | Links entries to images |
| EntryAsset | Links entries to assets |
| EntryLocation | Links entries to locations |
| ArticleCharacter | Links articles to characters |
| ImageCharacter | Links images to characters |
| AssetImage | Links assets to images |
| ImageLocation | Links images to locations |
| SourceLink | External URLs for a source |
| CharacterLink | External URLs for a character (Wikipedia, etc.) |

## Routes & Navigation

| Path | Description |
|------|-------------|
| `/` | Timeline view (chronological entries, assets, images) |
| `/entries` | All entries list |
| `/characters` | All people |
| `/sources` | All research sources |
| `/articles` | All newspaper articles |
| `/production_assets` | Production assets with card images |
| `/locations` | Filming locations |
| `/images` | Image gallery |
| `/search` | Search across all content |
| `/help` | Usage documentation |

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
│   ├── assets_controller.rb
│   ├── locations_controller.rb
│   ├── images_controller.rb
│   ├── timeline_controller.rb
│   └── search_controller.rb
├── models/
│   ├── entry.rb
│   ├── character.rb
│   ├── source.rb
│   ├── article.rb
│   ├── asset.rb
│   ├── location.rb
│   ├── image.rb
│   └── [junction tables...]
├── javascript/
│   └── controllers/
│       ├── gallery_picker_controller.js
│       ├── timeline_lightbox_controller.js
│       └── image_source_controller.js
├── views/
│   ├── entries/
│   ├── characters/
│   ├── sources/
│   ├── articles/
│   ├── assets/
│   ├── locations/
│   ├── images/
│   ├── timeline/
│   └── layouts/
└── assets/
    └── stylesheets/
        ├── application.css
        └── color_palette.css
```

## Stimulus Controllers

| Controller | Purpose |
|------------|---------|
| `gallery_picker_controller` | Visual image selection modal for assets with featured image support |
| `timeline_lightbox_controller` | Lightbox for viewing images on the timeline |
| `image_source_controller` | Toggle between file upload and URL import tabs |

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
- `Asset.by_name`, `Asset.by_type(type)`
- `Location.by_name`, `Location.by_type(type)`, `Location.by_country(country)`

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
8. **Date Precision** - Entry, Asset, and Image models support imprecise dates via `*_precision` fields
9. **Stimulus Controllers** - Interactive features use Stimulus.js controllers in `app/javascript/controllers/`
