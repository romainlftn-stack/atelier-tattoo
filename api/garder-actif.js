/* Garde le projet Supabase éveillé.
   Sur l'offre gratuite, Supabase met en pause tout projet resté sept jours
   sans activité — et l'atelier peut rester des semaines sans visite. Une tâche
   planifiée de Vercel (voir vercel.json) appelle cette fonction chaque jour ;
   elle lance une vraie requête sur la base, ce qui compte comme de l'activité.
   On passe par Vercel plutôt que par GitHub Actions : le dépôt est public, et
   GitHub y désactive les tâches planifiées après 60 jours sans commit — le
   projet serait alors retombé en pause sans prévenir.
   La clé est la clé publique déjà inscrite dans index.html : la requête ne
   voit que ce qu'un visiteur anonyme verrait, c'est-à-dire rien, les
   configurations étant protégées par RLS. Elle n'en passe pas moins par la
   base. */
const URL_SUPABASE = 'https://xbzawuxpcsaublrzwcpy.supabase.co';
const CLE_PUBLIQUE = 'sb_publishable_yJXk7hqaof-6IrKNZGw2ew_NBOBKxRZ';

module.exports = async function handler(req, res){
  const debut = Date.now();
  // Jamais de cache : une réponse gardée en mémoire par Vercel servirait la
  // tâche planifiée sans que la base soit jamais interrogée.
  res.setHeader('Cache-Control', 'no-store');
  try{
    const r = await fetch(`${URL_SUPABASE}/rest/v1/configurations?select=id&limit=1`, {
      headers: { apikey: CLE_PUBLIQUE, Authorization: `Bearer ${CLE_PUBLIQUE}` }
    });
    res.status(r.ok ? 200 : 502).json({ ok: r.ok, statut: r.status, ms: Date.now() - debut });
  }catch(e){
    res.status(502).json({ ok: false, erreur: String((e && e.message) || e) });
  }
};
