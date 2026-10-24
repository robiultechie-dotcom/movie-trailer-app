# frozen_string_literal: true

require 'digest'

# Generates deterministic fake movies with sequential 4-clip cyclic rotation (1->2->3->4->1).
class MoviesController < ApplicationController
  PER_PAGE = 10
  DEFAULT_LOCALE = 'en-US'
  DEFAULT_SEED = '58933423'

  LOCALE_DATA = {
    'en-US' => {
      faker_locale: :en,
      starring_text: 'STARRING',
      ui: {
        genre: 'Genre', title: 'Title', cast: 'Cast', year: 'Year',
        director: 'Director', review: 'Review', reviews: 'Reviews', min: 'min',
        language: 'Language', seed: 'Seed', likes: 'Likes'
      },
      genres: %w[Sci-Fi Drama Action Comedy Family Thriller Mystery Adventure],
      title_nouns: %w[Horizon Empire Echoes Shadows Legacy Odyssey Labyrinth Prophecy Protocol Sanctuary Kingdom Paradox],
      subtitles: %w[Midnight Dawn Awakening Reckoning Eclipse Retribution Origins Destiny Requiem Ascension Genesis Finale],
      title_adj: %w[Silent Eternal Shattered Crimson Forgotten Hidden Dark Final Golden Lost Midnight Infinite],
      hooks: [
        'THIS FALL', 'IN A WORLD OF SECRETS', 'ONE FINAL MISSION',
        'BEYOND IMAGINATION', 'TRUTH HAS A PRICE', 'DESTINY AWAITS'
      ],
      plots: [
        'After uncovering a classified conspiracy, a former operative must race against time to prevent a global catastrophe before midnight.',
        'In a quiet coastal town, two estranged siblings reunite to solve the mysterious disappearance of their family heritage.',
        'Cut off from communication in deep space, an exploration crew discovers an ancient artifact that challenges human history.',
        'A brilliant detective teams up with an unlikely ally to track down a mastermind orchestrating high-stakes heists across the metropolis.',
        'When an experimental technology goes rogue, a small group of survivors must navigate a shifting landscape to restore order.',
        'Caught between loyalty and justice, a seasoned journalist risks everything to expose the corruption hidden inside a powerful syndicate.'
      ],
      reviews: [
        'A breathtaking masterpiece with stunning visuals and a deeply moving storyline from start to finish.',
        'Brilliant performances by the lead cast keep you on the edge of your seat throughout the entire film.',
        'The pacing in the second act is phenomenal, supported by an unforgettable cinematic score and sharp direction.',
        'An ambitious and atmospheric thriller that delivers smart twists without losing its emotional core.',
        'Sharp dialogue and impressive cinematography make this one of the most compelling releases of the year.',
        'A captivating journey that balances intense action with genuine character development.'
      ]
    },
    'de-DE' => {
      faker_locale: :de,
      starring_text: 'IN DER HAUPTROLLE',
      ui: {
        genre: 'Genre', title: 'Titel', cast: 'Besetzung', year: 'Jahr',
        director: 'Regie', review: 'Bewertung', reviews: 'Bewertungen', min: 'Min.',
        language: 'Sprache', seed: 'Seed', likes: 'Likes'
      },
      genres: %w[Sci-Fi Drama Action Komödie Familie Thriller Krimi Abenteuer],
      title_nouns: %w[Horizont Imperium Echos Schatten Vermächtnis Odyssee Labyrinth Prophezeiung Protokoll Zuflucht Königreich Paradoxon],
      noun_genders: %i[m n pl pl n f n f n f n n],
      subtitles: %w[Mitternacht Morgengrauen Erwachen Abrechnung Finsternis Vergeltung Ursprung Schicksal Requiem Aufstieg Genesis Finale],
      title_adj: {
        m:  %w[Stiller Ewiger Zerbrochener Purpurner Vergessener Verborgener Dunkler Letzter Goldener Verlorener Mitternächtlicher Unendlicher],
        f:  %w[Stille Ewige Zerbrochene Purpurne Vergessene Verborgene Dunkle Letzte Goldene Verlorene Mitternächtliche Unendliche],
        n:  %w[Stilles Ewiges Zerbrochenes Purpurnes Vergessenes Verborgenes Dunkles Letztes Goldenes Verlorenes Mitternächtliches Unendliches],
        pl: %w[Stille Ewige Zerbrochene Purpurne Vergessene Verborgene Dunkle Letzte Goldene Verlorene Mitternächtliche Unendliche]
      },
      hooks: [
        'DIESEN HERBST', 'IN EINER WELT VOLLER GEHEIMNISSE', 'DIE LETZTE MISSION',
        'JENSEITS DER VORSTELLUNG', 'DIE WAHRHEIT HAT IHREN PREIS', 'DAS SCHICKSAL WARTET'
      ],
      plots: [
        'Nach der Aufdeckung einer geheimen Verschwörung muss ein ehemaliger Agent gegen die Zeit antreten, um eine globale Katastrophe vor Mitternacht zu verhindern.',
        'In einer ruhigen Küstenstadt kommen zwei entfremdete Geschwister zusammen, um das mysteriöse Verschwinden ihres Familienerbes aufzuklären.',
        'Abgeschnitten von der Kommunikation im tiefen Weltraum entdeckt eine Forschungscrew ein uraltes Artefakt, das die Menschheitsgeschichte infrage stellt.',
        'Ein brillanter Detektiv verbündet sich mit einem ungewöhnlichen Partner, um einen genialen Drahtzieher hinter riskanten Raubzügen in der Metropole zu fassen.',
        'Als eine experimentelle Technologie außer Kontrolle gerät, muss eine kleine Gruppe von Überlebenden durch eine veränderte Welt navigieren, um die Ordnung wiederherzustellen.',
        'Gefangen zwischen Loyalität und Gerechtigkeit setzt ein erfahrener Journalist alles aufs Spiel, um die Korruption innerhalb eines mächtigen Syndikats zu enthüllen.'
      ],
      reviews: [
        'Ein atemberaubendes Meisterwerk mit beeindruckenden Bildern und einer tief bewegenden Geschichte von Anfang bis Ende.',
        'Brillante Darstellungen der Hauptdarsteller sorgen durchgehend für höchste Spannung im gesamten Film.',
        'Das Tempo im zweiten Akt ist phänomenal, unterstützt von einer unvergesslichen Filmmusik und präziser Regie.',
        'Ein ehrgeiziger und atmosphärischer Thriller, der kluge Wendungen liefert, ohne seinen emotionalen Kern zu verlieren.',
        'Scharfe Dialoge und eine erstklassige Kameraführung machen diesen Film zu einer der fesselndsten Veröffentlichungen des Jahres.',
        'Eine fesselnde Reise, die intensive Action perfekt mit glaubwürdiger Charakterentwicklung verbindet.'
      ]
    },
    'fr-FR' => {
      faker_locale: :fr,
      starring_text: 'AVEC',
      ui: {
        genre: 'Genre', title: 'Titre', cast: 'Distribution', year: 'Année',
        director: 'Réalisateur', review: 'Critique', reviews: 'Critiques', min: 'min',
        language: 'Langue', seed: 'Seed', likes: 'Likes'
      },
      genres: ['Science-fiction', 'Drame', 'Action', 'Comédie', 'Famille', 'Thriller', 'Mystère', 'Aventure'],
      title_nouns: %w[Horizon Empire Échos Ombres Héritage Odyssée Labyrinthe Prophétie Protocole Sanctuaire Royaume Paradoxe],
      noun_genders: %i[m m mpl fpl m f m f m m m m],
      subtitles: %w[Minuit Aube Éveil Jugement Éclipse Châtiment Origines Destin Requiem Ascension Genèse Épilogue],
      title_adj: {
        m:   %w[Silencieux Éternel Brisé Pourpre Oublié Caché Sombre Final Doré Perdu Nocturne Infini],
        f:   %w[Silencieuse Éternelle Brisée Pourpre Oubliée Cachée Sombre Finale Dorée Perdue Nocturne Infinie],
        mpl: %w[Silencieux Éternels Brisés Pourpres Oubliés Cachés Sombres Finaux Dorés Perdus Nocturnes Infinis],
        fpl: %w[Silencieuses Éternelles Brisées Pourpres Oubliées Cachées Sombres Finales Dorées Perdues Nocturnes Infinies]
      },
      hooks: [
        'CET AUTOMNE', 'DANS UN MONDE DE SECRETS', 'UNE DERNIÈRE MISSION',
        'AU-DELÀ DE L’IMAGINATION', 'LA VÉRITÉ A UN PRIX', 'LE DESTIN ATTEND'
      ],
      plots: [
        'Après avoir découvert un complot secret, un ancien agent doit faire une course contre la montre pour empêcher une catastrophe mondiale avant minuit.',
        'Dans une paisible ville côtière, deux frères et sœurs séparés se réunissent pour résoudre la mystérieuse disparition de leur héritage familial.',
        'Coupé de toute communication dans l’espace lointain, un équipage d’exploration découvre un ancien artefact qui remet en question l’histoire humaine.',
        'Un brillant détective s’associe à un allié inattendu pour traquer un cerveau orchestrant des braquages de haut vol à travers la métropole.',
        'Lorsqu’une technologie expérimentale échappe à tout contrôle, un petit groupe de survivants doit naviguer dans un monde en mutation pour rétablir l’ordre.',
        'Pris entre loyauté et justice, un journaliste chevronné risque tout pour dénoncer la corruption cachée au sein d’un puissant syndicat.'
      ],
      reviews: [
        'Un chef-d’œuvre à couper le souffle avec des visuels époustouflants et une histoire profondément émouvante du début à la fin.',
        'Les performances brillantes des acteurs principaux vous tiennent en haleine tout au long du film.',
        'Le rythme du deuxième acte est phénoménal, soutenu par une musique inoubliable et une réalisation impeccable.',
        'Un thriller ambitieux et atmosphérique qui offre des rebondissements intelligents sans perdre son cœur émotionnel.',
        'Des dialogues percutants et une photographie impressionnante font de ce film l’une des sorties les plus marquantes de l’année.',
        'Un voyage captivant qui équilibre parfaitement une action intense et un développement sincère des personnages.'
      ]
    }
  }.freeze

  def index
    @locale    = LOCALE_DATA.key?(params[:locale]) ? params[:locale] : DEFAULT_LOCALE
    @ui        = LOCALE_DATA[@locale][:ui]
    @seed      = (params[:seed].presence || DEFAULT_SEED).to_s
    @likes     = rate_param(:likes, 0.0)
    @reviews   = rate_param(:reviews, 2.3)
    @page      = [params[:page].to_i, 1].max
    @view_mode = params[:view_mode] == 'gallery' ? 'gallery' : 'table'

    first = (@page - 1) * PER_PAGE + 1
    @movies = (first...(first + PER_PAGE)).map { |index| generate_movie(index) }
  end

  private

  def rate_param(key, default)
    (params[key].presence || default).to_f.clamp(0.0, 10.0)
  end

  def rng_for(*parts)
    Random.new(Digest::SHA256.hexdigest(parts.join('-'))[0, 16].to_i(16))
  end

  def fractional_count(average, rng)
    average.floor + (rng.rand < average % 1 ? 1 : 0)
  end

  def clean_person_name(locale_code, rng)
    dict = LOCALE_DATA[locale_code]
    Faker::Config.locale = dict[:faker_locale]
    Faker::Config.random = rng
    "#{Faker::Name.first_name} #{Faker::Name.last_name}"
  rescue StandardError
    Faker::Name.name
  end

  def generate_movie(index)
    dict = LOCALE_DATA[@locale]

    struct_rng = rng_for(@seed, 'core_structure', index)
    adj_idx    = struct_rng.rand(12)
    noun_idx   = struct_rng.rand(12)
    sub_idx    = struct_rng.rand(12)
    has_sub    = struct_rng.rand < 0.3
    genre_idx  = struct_rng.rand(dict[:genres].size)
    year       = struct_rng.rand(1990..2025)
    cast_count = struct_rng.rand(3..5)
    plot_idx   = struct_rng.rand(dict[:plots].size)
    hook_idx   = struct_rng.rand(dict[:hooks].size)

    # Strictly sequential clip rotation: 1 -> clip1, 2 -> clip2, 3 -> clip3, 4 -> clip4, 5 -> clip1 ...
    clip_number = ((index - 1) % 4) + 1
    zoom = [1.05, 1.1, 1.15].sample(random: struct_rng)

    adjective = if dict[:title_adj].is_a?(Hash)
                  gender = dict[:noun_genders][noun_idx]
                  dict[:title_adj][gender][adj_idx]
                else
                  dict[:title_adj][adj_idx]
                end

    noun     = dict[:title_nouns][noun_idx]
    subtitle = dict[:subtitles][sub_idx]

    title = if @locale == 'fr-FR'
              has_sub ? "#{noun} #{adjective} : #{subtitle}" : "#{noun} #{adjective}"
            else
              has_sub ? "#{adjective} #{noun}: #{subtitle}" : "#{adjective} #{noun}"
            end

    cast = Array.new(cast_count) do |n|
      clean_person_name(@locale, rng_for(@seed, @locale, 'actor', index, n))
    end.join(', ')

    director = clean_person_name(@locale, rng_for(@seed, @locale, 'director', index))

    {
      index: index, title: title, genre: dict[:genres][genre_idx], year: year,
      cast: cast, director: director, plot: dict[:plots][plot_idx],
      trailer: {
        clip: "clip#{clip_number}",
        hook: dict[:hooks][hook_idx],
        starring_text: dict[:starring_text],
        zoom: zoom
      },
      likes: fractional_count(@likes, rng_for(@seed, 'likes', index)),
      reviews: generate_reviews(dict, index)
    }
  end

  def generate_reviews(dict, index)
    total = fractional_count(@reviews, rng_for(@seed, 'reviews_count', index))

    (1..total).map do |n|
      text_rng = rng_for(@seed, 'review_text', index, n)
      body = dict[:reviews][text_rng.rand(dict[:reviews].size)]

      Faker::Config.locale = dict[:faker_locale]
      Faker::Config.random = rng_for(@seed, @locale, 'review_company', index, n)
      company = Faker::Company.name

      author = clean_person_name(@locale, rng_for(@seed, @locale, 'review_author', index, n))
      { body: body, author: author, company: company }
    end
  end
end
