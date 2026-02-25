import { createClient } from '@/lib/supabase/server'

export default async function HomePage() {
    const supabase = await createClient()

    const { data: products, error } = await supabase
        .from('products')
        .select('name, price')
        .limit(5)

    if (error) {
        return <div>Connection failed: {error.message}</div>
    }

    return (
        <div>
            <h1>Velura — Connection Test</h1>
            <ul>
                {products.map((p) => (
                    <li key={p.name}>{p.name} — AED {p.price}</li>
                ))}
            </ul>
        </div>
    )
}
