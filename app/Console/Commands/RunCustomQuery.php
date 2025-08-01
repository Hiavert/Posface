<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class RunCustomQuery extends Command
{
    protected $signature = 'run:custom-query';
    protected $description = 'Ejecuta un query gigante desde un archivo SQL, ignorando errores y continuando con las demás sentencias.';

    public function handle()
    {
        $path = database_path('scripts/posface.sql'); // 👈 Asegurate de que el nombre coincida

        if (!file_exists($path)) {
            $this->error("No se encontró el archivo SQL en: $path");
            return 1;
        }

        $sqlContent = file_get_contents($path);
        $statements = array_filter(array_map('trim', explode(";", $sqlContent)));

        $this->info("🚀 Ejecutando " . count($statements) . " sentencias SQL...");

        $errores = [];

        foreach ($statements as $index => $statement) {
            if (empty($statement)) continue;

            try {
                DB::unprepared($statement);
                $this->info("✅ Sentencia #" . ($index + 1) . " ejecutada correctamente.");
            } catch (\Throwable $e) {
                $errorMsg = "❌ Error en sentencia #" . ($index + 1) . ": " . $e->getMessage();
                $this->error($errorMsg);
                $errores[] = $errorMsg;
                // 🔥 sigue ejecutando el resto aunque falle esta
            }
        }

        if (!empty($errores)) {
            $this->warn("⚠️ Algunas sentencias fallaron. Revisa storage/logs/laravel.log para más detalles.");
            return 1;
        }

        $this->info("🎉 Query ejecutado completamente (con o sin errores).");
        return 0;
    }
}
