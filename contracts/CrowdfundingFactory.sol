// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Campaign.sol";

/// @title CrowdfundingFactory — Fabrica de Campanas de Crowdfunding
/// @author Estudiante del Curso de Blockchain
/// @notice Crea y registra campanas de crowdfunding usando el patron Factory.
contract CrowdfundingFactory {

    // ── Constantes ───────────────────────────────────────────

    /// @notice Meta minima permitida para una campana
    uint256 public constant META_MINIMA = 0.01 ether;

    // ── Variables de Estado ──────────────────────────────────

    /// @notice Array de todas las campanas creadas
    Campaign[] public campanas;

    // ── Eventos ──────────────────────────────────────────────

    /// @notice Se emite cuando se crea una nueva campana
    event CampanaCreada(
        address indexed direccionCampana,
        address indexed creador,
        string titulo,
        uint256 metaRecaudacion
    );

    // ── Funciones Principales ────────────────────────────────

    /// @notice Crea una nueva campana de crowdfunding
    /// @param _titulo Titulo de la campana
    /// @param _descripcion Descripcion de la campana
    /// @param _metaRecaudacion Meta de recaudacion en wei
    /// @param _duracionEnDias Duracion de la campana en dias
    function crearCampana(
        string memory _titulo,
        string memory _descripcion,
        uint256 _metaRecaudacion,
        uint256 _duracionEnDias
    ) external {
        require(_metaRecaudacion >= META_MINIMA, "La meta debe ser al menos 0.01 ETH");
        require(_duracionEnDias >= 1 && _duracionEnDias <= 365, "La duracion debe ser entre 1 y 365 dias");

        Campaign nuevaCampana = new Campaign(
            msg.sender,
            _titulo,
            _descripcion,
            _metaRecaudacion,
            _duracionEnDias
        );

        campanas.push(nuevaCampana);

        emit CampanaCreada(address(nuevaCampana), msg.sender, _titulo, _metaRecaudacion);
    }

    // ── Funciones de Consulta ────────────────────────────────

    /// @notice Obtiene todas las campanas creadas
    /// @return Array de contratos Campaign
    function obtenerCampanas() public view returns (Campaign[] memory) {
        return campanas;
    }

    /// @notice Obtiene el numero total de campanas
    /// @return Cantidad de campanas creadas
    function obtenerNumeroCampanas() public view returns (uint256) {
        return campanas.length;
    }

    /// @notice Obtiene los detalles de una campana por indice
    /// @param _indice Indice de la campana en el array
    /// @return direccionCampana Direccion del contrato Campaign
    /// @return _titulo Titulo
    /// @return _creador Creador
    /// @return _metaRecaudacion Meta
    /// @return _totalRecaudado Total recaudado
    /// @return _estado Estado actual
    function obtenerDetallesCampana(uint256 _indice) public view returns (
        address direccionCampana,
        string memory _titulo,
        address _creador,
        uint256 _metaRecaudacion,
        uint256 _totalRecaudado,
        Campaign.EstadoCampana _estado
    ) {
        require(_indice < campanas.length, "Indice fuera de rango");

        Campaign campana = campanas[_indice];
        return (
            address(campana),
            campana.titulo(),
            campana.creador(),
            campana.metaRecaudacion(),
            campana.totalRecaudado(),
            campana.obtenerEstado()
        );
    }
}
