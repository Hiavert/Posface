<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Region extends Model
{
    protected $table = 'regiones';
    protected $primaryKey = 'id_region';
    protected $fillable = ['nombre'];
}