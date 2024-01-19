[Mesh]
  construct_side_list_from_node_list = true
  [matrix_fracture]
    type = FileMeshGenerator
    file = cube_16m_fracture_half_c4.msh
  []
  [injection_node_set]
    type = ExtraNodesetGenerator
    input = matrix_fracture
    coord = '0 0 0'
    new_boundary = 'injection_node_set'
  []
  [fracture]
    type = LowerDBlockFromSidesetGenerator
    sidesets = 'fracture'
    new_block_name = 'fracture'
    input = injection_node_set
  []
  use_displaced_mesh = false
[]

[GlobalParams]
  multiply_by_density = true
  gravity = '0 0 0'
[]

[Variables]
  [pressure]
    initial_condition = 1e7
  []
  [tracer]
    initial_condition = 0
    block = 'fracture'
  []
[]

[AuxVariables]
  [velocity_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [velocity_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [grad_p_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [density]
    family = MONOMIAL
    order = CONSTANT
  []
  [viscosity]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [perm_z]
    family = MONOMIAL
    order = CONSTANT
  []
  [porosity]
    family = MONOMIAL
    order = CONSTANT
  []
[]

[AuxKernels]
  [velocity_x]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_x
    component = x
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [velocity_y]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_y
    component = y
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [velocity_z]
    type = PorousFlowDarcyVelocityComponent
    variable = velocity_z
    component = z
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [velocity_xf]
    type = PorousFlowDarcyVelocityComponentLowerDimensional
    variable = velocity_x
    component = x
    block = 'fracture'
    aperture = '1e-4'
    PorousFlowDictator = dictator1
  []
  [velocity_yf]
    type = PorousFlowDarcyVelocityComponentLowerDimensional
    variable = velocity_y
    component = y
    block = 'fracture'
    aperture = '1e-4'
    PorousFlowDictator = dictator1
  []
  [velocity_zf]
    type = PorousFlowDarcyVelocityComponentLowerDimensional
    variable = velocity_z
    component = z
    block = 'fracture'
    aperture = '1e-4'
    PorousFlowDictator = dictator1
  []
  [density]
    type = PorousFlowPropertyAux
    variable = density
    property = density
    PorousFlowDictator = dictator1
  []
  [viscosity]
    type = PorousFlowPropertyAux
    variable = viscosity
    property = viscosity
    PorousFlowDictator = dictator1
  []
  [porosity]
    type = PorousFlowPropertyAux
    variable = porosity
    property = porosity
    PorousFlowDictator = dictator1
  []
  [perm_x]
    type = PorousFlowPropertyAux
    variable = perm_x
    property = permeability
    row = 0
    column = 0
    PorousFlowDictator = dictator1
  []
  [perm_y]
    type = PorousFlowPropertyAux
    variable = perm_y
    property = permeability
    row = 1
    column = 1
    PorousFlowDictator = dictator1
  []
  [perm_z]
    type = PorousFlowPropertyAux
    variable = perm_z
    property = permeability
    row = 2
    column = 2
    PorousFlowDictator = dictator1
  []
  [grad_p_x]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_x
    component = 0
    property = PorousFlow_grad_porepressure_qp
  []
  [grad_p_y]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_y
    component = 1
    property = PorousFlow_grad_porepressure_qp
  []
  [grad_p_z]
    type = MaterialStdVectorRealGradientAux
    variable = grad_p_z
    component = 2
    property = PorousFlow_grad_porepressure_qp
  []
[]

[BCs]
  [p_right]
    type = DirichletBC
    boundary = 'right'
    value = 1e7
    variable = pressure
  []
  [tracer_in]
    type = DirichletBC
    boundary = 'injection_node_set'
    value = 0.1
    variable = tracer
  []
  [tracer_right]
    type = DirichletBC
    boundary = 'right'
    value = 0
    variable = tracer
  []
[]

[DiracKernels]
  [inj]
    type = PorousFlowSquarePulsePointSource
    start_time = 0
    point = '0 0 0'
    mass_flux = 1 # kg/s
    variable = pressure
    point_not_found_behavior = WARNING
  []
[]

[Kernels]
  [mass1a]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = pressure
    PorousFlowDictator = dictator2
    block = 'left right'
  []
  [adv1a]
    type = PorousFlowFullySaturatedAdvectiveFlux
    fluid_component = 0
    variable = pressure
    PorousFlowDictator = dictator2
    block = 'left right'
  []
  [mass1b]
    type = PorousFlowMassTimeDerivative
    fluid_component = 1
    variable = pressure
    PorousFlowDictator = dictator1
    block = 'fracture'
  []
  [adv1b]
    type = PorousFlowFullySaturatedAdvectiveFlux
    fluid_component = 1
    variable = pressure
    PorousFlowDictator = dictator1
    block = 'fracture'
  []
  [adv0]
    type = PorousFlowFullySaturatedAdvectiveFlux
    fluid_component = 0
    variable = tracer
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [mass0]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = tracer
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [disp0]
    type = PorousFlowDispersiveFlux
    fluid_component = 0
    variable = tracer
    disp_trans = 0
    disp_long = 0
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
[]

[UserObjects]
  [dictator1]
    type = PorousFlowDictator
    porous_flow_vars = 'pressure tracer'
    number_fluid_phases = 1
    number_fluid_components = 2
  []
  [dictator2]
    type = PorousFlowDictator
    porous_flow_vars = 'pressure'
    number_fluid_phases = 1
    number_fluid_components = 1
  []
[]

[FluidProperties]
  [fluid]
    type = SimpleFluidProperties
    bulk_modulus = 2e+9
    density0 = 1000
    thermal_expansion = 0
    viscosity = 1e-4
  []
[]

[Materials]
  [temperature1]
    type = PorousFlowTemperature
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [temperature2]
    type = PorousFlowTemperature
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [ppss1]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pressure
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [ppss2]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pressure
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [massfrac1]
    type = PorousFlowMassFraction
    mass_fraction_vars = 'tracer'
    PorousFlowDictator = dictator1
    block = 'fracture'
  []
  [massfrac2]
    type = PorousFlowMassFraction
    PorousFlowDictator = dictator2
    block = 'left right'
  []
  [single_fluid1]
    type = PorousFlowSingleComponentFluid
    fp = fluid
    phase = 0
    PorousFlowDictator = dictator1
    block = 'fracture'
  []
  [single_fluid2]
    type = PorousFlowSingleComponentFluid
    fp = fluid
    phase = 0
    PorousFlowDictator = dictator2
    block = 'left right'
  []
  [poro_fracture]
    type = PorousFlowPorosityConst
    porosity = '1e-4' # a = 1e-4
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [poro_matrix]
    type = PorousFlowPorosityConst
    porosity = '1e-1'
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [diff1]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0 0'
    tortuosity = 1
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [diff2]
    type = PorousFlowDiffusivityConst
    diffusion_coeff = '0'
    tortuosity = 1
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [permeability_matrix]
    type = PorousFlowPermeabilityConst
    permeability = '1E-20 0 0 0 1E-20 0 0 0 1E-20'
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [permeability_fracture]
    type = PorousFlowPermeabilityConstFromVar
    perm_xx = 8.333333e-14 # a=1e-4
    perm_yy = 8.333333e-14 # a=1e-4
    perm_zz = 8.333333e-14 # a=1e-4
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [relp1]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
    kr = 1
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [relp2]
    type = PorousFlowRelativePermeabilityConst
    phase = 0
    kr = 1
    block = 'left right'
    PorousFlowDictator = dictator2
  []
  [darcy_velocity_qp1]
    type = PorousFlowDarcyVelocityMaterial
    block = 'fracture'
    PorousFlowDictator = dictator1
  []
  [darcy_velocity_qp2]
    type = PorousFlowDarcyVelocityMaterial
    block = 'left right'
    PorousFlowDictator = dictator2
  []
[]

[Preconditioning]
  active = 'mumps'
  [mumps]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix -ksp_gmres_modifiedgramschmidt'
    petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package -pc_factor_shift_type -snes_rtol -snes_atol -snes_max_it -ksp_atol -ksp_rtol'
    petsc_options_value = 'gmres      lu       mumps                         NONZERO               1E-10       1E-10       100         1E-10     1E-18'
  []
[]

[Executioner]
  type = Transient
  solve_type = NEWTON
  end_time = 10
  dt = 0.5
[]

[Outputs]
  print_linear_residuals = true
  print_nonlinear_residuals = true
  perf_graph = true
  checkpoint = true
  exodus = true
  [debug]
    type = VariableResidualNormsDebugOutput
  []
[]
