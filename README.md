# Atelier Tattoo 3D

Studio de projection de flashs sur anatomie 3D réelle. Aucune installation :
`index.html` + `anatomie.bin` (le maillage anatomique) + le lanceur.

## Démarrer

**Le plus simple** : double-cliquer sur `Lancer l'atelier.command`.
Le navigateur s'ouvre tout seul. Laisser la fenêtre Terminal ouverte pendant
l'utilisation.

Alternative manuelle :

```bash
cd "Atelier Tattoo 3D" && python3 -m http.server 8080
```

puis ouvrir `http://localhost:8080`.

> L'application a besoin d'un serveur local (le lanceur s'en charge) : elle
> charge `anatomie.bin` et la librairie 3D en modules. Une connexion internet
> est nécessaire **au premier chargement seulement** (la librairie 3D vient d'un
> CDN, puis le navigateur la met en cache). `anatomie.bin` est local.
> Ajouter `?demo=1` à l'URL charge un motif d'exemple déjà posé.

## Modèles

Le maillage anatomique est le **corps de référence MakeHuman**, publié
explicitement en **CC0** (domaine public) : 14 517 sommets, 26 756 triangles,
vrai visage, vraies mains à cinq doigts avec ongles, vrais pieds. Voir
`LICENCES.md`.

| Onglet | Contenu |
|---|---|
| **Bras** | Bras + main, section franche à mi-humérus ; côté droit/gauche |
| **Jambe** | Membre entier + pied, sectionné en haut de cuisse |
| **Corps entier** | Corps complet à l'échelle réelle (1 unité = 1 mètre) |
| **Importé** | Apparaît dès qu'un `.glb` est chargé |

### Morphologie

Le **genre** se choisit par bouton (Homme / Femme). Les curseurs **musculature**
et **corpulence** appliquent les *cibles de morphing d'origine de MakeHuman*,
**distinctes pour chaque genre** — un corps féminin reçoit des volumes féminins,
sinon la silhouette devient incohérente.

Par-dessus ces cibles, un **sculpt volumétrique** dilate le rayon autour de
l'axe de chaque segment osseux, avec un maximum au ventre du muscle et un
mélange lissé entre segments. C'est ce qui fait qu'un bras « très musclé » est
réellement massif, là où les cibles seules ne modifient guère que le galbe.

Le modèle est à l'échelle 1,78 m, ce qui garde les dimensions de tatouage
justes en centimètres.

**Poing** : curseur continu de la main ouverte au poing fermé, plus trois
raccourcis. **Doigts écartés** règle l'abduction.

Chaque sommet de main porte, calculée hors ligne, son **appartenance à un
doigt** (partition de Voronoï sur les chaînes de phalanges) et son abscisse le
long de ce doigt. La flexion ne touche donc que les sommets du bon doigt :
aucune contamination de la paume ni des doigts voisins. Les repères
articulaires **suivent le morphing**, sinon la chaîne se décale du maillage dès
que le genre ou la corpulence change.

### Modèle externe

Glissez un fichier **`.glb`** dans la fenêtre, ou *Importer un modèle GLB…*.
Le fichier est mis à l'échelle sur la stature réglée, recentré, et son éventuel
squelette est figé dans sa pose de repos.

**Les curseurs continuent de fonctionner sur un modèle importé** : musculature,
corpulence, épaules, hanches et stature déforment le maillage (dilatation
radiale autour de l'axe, calculée tranche par tranche), et la carnation se
multiplie par-dessus l'albédo d'origine.

Sources : MakeHuman, Sketchfab en filtre CC0, Ready Player Me, figures de base
Daz Studio, Human Generator pour Blender, ou un modèle acheté (TurboSquid,
CGTrader) converti en `.glb` depuis Blender (*File → Export → glTF 2.0*, cocher
« Include textures »).

## Poser un tatouage

1. Glisser des **PNG ou JPG** dans le panneau de gauche (ou *Charger un motif d'exemple*).
2. Le mode bascule sur **Placer** — cliquer sur le corps.
3. Glisser le calque pour le promener sur la peau : il se re-projette en temps réel
   et épouse le relief.

| Geste | Effet |
|---|---|
| Clic gauche + glisser (fond) | Orbiter |
| Molette | Zoom |
| Clic droit + glisser | Translater |
| Glisser un tatouage | Le déplacer sur la peau |
| **Alt** + glisser | Le faire pivoter |
| **Maj** + glisser | Le redimensionner |
| ← / → | Rotation fine (Maj = 5×) |
| `D` `M` `Suppr` | Dupliquer · Symétriser · Supprimer |
| `T` | Thème clair / sombre |
| `F` `Z` `P` | Recadrer · Zoom calque · Export rendu |
| `Tab` | Basculer Naviguer / Placer |
| Cmd/Ctrl+Z | Annuler (Maj pour rétablir) |

### Les calques suivent le corps, pas la vue

Chaque tatouage est mémorisé dans le **repère anatomique du maillage de base**,
pas en coordonnées d'écran. Un motif posé en vue *Bras* réapparaît sur le même
bras, au même endroit, en vue *Corps entier* — et inversement. Idem pour la
jambe.

Chaque calque retient aussi **sa région** (bras gauche/droit, jambe
gauche/droite, tronc), déterminée par proximité aux chaînes osseuses. Deux
conséquences :

- Quand le membre concerné n'est pas affiché (un tatouage de cuisse en vue
  *Bras*), le calque est masqué, pas déplacé. Il reste dans la liste et revient
  dès qu'on retourne sur la bonne vue.
- En basculant sur *Bras* ou *Jambe*, **le côté affiché suit les calques** : si
  vos motifs sont sur le bras droit, c'est le bras droit qui s'affiche.

Le recollage sur la surface n'est accepté que si celle-ci se trouve bien là où
on l'attend. Sans ce garde-fou, en passant du corps à la jambe, un tatouage de
bras était reprojeté dans la nouvelle vue et le lancer de rayon l'accrochait à
la cuisse — il migrait définitivement.

La projection est une décalcomanie volumétrique : un même tatouage à cheval sur
l'épaule et le torse génère une géométrie par surface traversée, donc pas de
rupture aux jonctions. Les dimensions affichées sont en **centimètres réels**.

## Détourage automatique

À l'import, le fond est analysé et le mode adéquat est choisi. **Les pixels
transparents sont exclus de toutes les statistiques** : sans ça, un PNG à fond
transparent est pris pour un motif clair sur fond noir, le détourage s'inverse
à tort et le calque ressort vide.

Un PNG qui possède une vraie transparence utilise donc directement son canal
alpha, et s'il est coloré, il arrive en **Origine** — un logo orange sur fond
transparent se pose tel quel.

- **Luminance** — un JPG sur fond blanc devient de l'encre seule ; les blancs
  intérieurs du motif deviennent transparents (la peau ressort à travers).
- **Fond uniquement** — remplissage par diffusion depuis les bords ; conserve les
  blancs intérieurs (utile pour le white ink ou les motifs opaques).
- **Alpha d'origine** — respecte le canal alpha d'un PNG déjà détouré.

**Encre : Noir / Blanc / Origine.** Un logo PNG à fond transparent se garde tel
quel (*Origine*), ou se reverse en noir ou en blanc sur fond transparent. La
pipette du panneau Calque reste disponible pour une teinte précise.

Réglages : seuil, douceur du bord, contraste, nettoyage des poussières
(suppression des composantes connexes trop petites), érosion/dilatation,
inversion (motif clair sur fond sombre), conservation des couleurs.
*Appliquer à tout* propage le réglage à toute la galerie.

## Rendu de l'encre

Chaque calque a ses propres réglages : couleur d'encre (noir, noir bleuté, grey
wash, estompé, vert ancien), opacité, **cicatrisation** (diffusion sous-cutanée
et perte de densité d'un tatouage ancien), **fraîcheur** (halo d'irritation +
brillance d'un tatouage du jour), **relief**, étirement, enfoncement de la
projection, orientation (verticale / axe du membre / libre), miroir, verrouillage.
L'encre hérite du micro-relief de la peau pour ne pas ressembler à un autocollant.

## Éclairage

Le panneau tient en six réglages : **ambiance** (8 configurations prêtes —
studio 3 points, Rembrandt, clamshell, ring light, soleil dur, néon,
contre-jour, softbox), **intensité** générale, **température** générale,
**exposition**, **fond**, **ombres portées**.

*Réglages avancés* déplie la gestion source par source : ajout/retrait, type
(spot / ponctuelle / directionnelle), intensité, Kelvin, teinte, cône,
diffusion, distance, azimut, hauteur, ombres, ambiance HDR, repères et
**manipulateur 3D** dans la scène.

La source marquée « principale » alimente la **diffusion sous-cutanée** de la peau
(back-scatter + wrap lighting), réglable par le curseur *Sous-surface*.

Global : exposition, ambiance HDR, fond, ombres portées, tonemapping ACES.

## Peau

Au chargement, l'application **rastérise les UV du maillage** pour obtenir, texel
par texel, la position et la normale en 3D. Elle peut alors peindre la peau à
l'endroit anatomiquement juste, et échantillonner le grain **dans l'espace 3D** —
donc sans couture visible, contrairement à une texture répétée.

Ce que ça produit :

- **Grain** calé au centimètre : pores, micro-relief, marbrures lentes.
- **Rupture du reflet** : c'est la variation de rugosité, plus que la couleur,
  qui fait lire une surface comme de la peau.
- **Veines** en stries continues suivant l'axe réel de chaque membre
  (avant-bras, dos de la main, bras, mollet), en relief dans la carte de
  normales et légèrement bleutées. Curseur *Veines*, atténué par la corpulence,
  accentué par la musculature.
- **Rougeurs articulaires** placées sur les repères du squelette : coudes,
  genoux, articulations des doigts, chevilles, mâchoire.
- **Faces internes plus claires**, faces postérieures plus sourdes et plus mates.
- **Capillaires**, éphélides, occlusion de cavité pré-calculée par sommet
  (creux, aisselles, plis).

Réglages : carnation (8 phototypes), teinte, grain, sébum, rougeurs, veines,
diffusion sous-cutanée.

## Thème

**Apparence : Sombre / Clair** — sélecteur dans le panneau « Caméra & rendu »,
bouton ☾ / ☀ dans la barre du haut, ou touche `T` : bascule toute l'interface
et le fond 3D entre mode sombre et mode clair. Le choix est mémorisé et
enregistré dans le projet. Le sélecteur *Fond* propose en plus un blanc studio,
un noir profond, un gris neutre, un fond chaud et un fond transparent.

## Export & projet

- **Rendu** : PNG jusqu'à 3× la résolution écran (fond transparent possible via
  *Fond → Transparent*).
- **Sauver / Charger** : le projet complet en JSON — morphologie, éclairage,
  caméra, motifs (images embarquées) et calques.

## Performances

- **Grille spatiale** sur le maillage : la projection d'un tatouage ne teste que
  les triangles du voisinage au lieu des 26 756 du corps. Le maillage local est
  mis en cache tant que le motif reste dedans. Déplacer un tatouage passe de
  ~36 ms à **~1 ms** par image.
- **Rendu à la demande** : la scène n'est redessinée que lorsqu'elle change.
  Au repos, l'indicateur affiche « prêt » et le GPU ne travaille pas.
- Re-projection des calques **différée au relâchement** du curseur de
  morphologie, au lieu d'à chaque cran.
- Cartes d'ombre en 1024, voile de brillance allégé sur la peau.
