<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TipoDocumento extends Model
{
    protected $table = 'tipo_documento';
    protected $primaryKey = 'id_tipo';
    protected $fillable = [
        'nombre_tipo',
        'descripcion',
    ];
} 