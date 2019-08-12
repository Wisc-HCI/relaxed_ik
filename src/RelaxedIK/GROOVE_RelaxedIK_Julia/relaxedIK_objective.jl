
# objectives should be written with respect to x and vars.  Closure will be made later automatically.

using LinearAlgebra
using StaticArrays
using Rotations
include("../Utils_Julia/transformations.jl")
include("../Utils_Julia/joint_utils.jl")
include("../Utils_Julia/geometry_utils.jl")
include("../Utils_Julia/nn_utils.jl")

function groove_loss(x_val, t, d, c, f, g)
    return (-2.718281828459^((-(x_val - t)^d) / (2.0 * c^2)) ) + f * (x_val - t)^g
end

function groove_loss_derivative(x_val, t, d, c, f, g)
    return -2.718281828459^((-(x_val - t)^d) / (2.0 * c^2)) * ( (-d*(x_val-t) ) / (2. * c^2) ) + g*f*(x_val-t)
end

function position_obj(x, vars, idx)
    vars.robot.arms[idx].getFrames(x[vars.robot.subchain_indices[idx]])
    goal = vars.goal_positions[idx] + vars.noise.base_noise.position
    x_val = norm(vars.robot.arms[idx].out_pts[end] - goal)

    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function rotation_obj(x, vars, idx)
    vars.robot.arms[idx].getFrames(x[vars.robot.subchain_indices[idx]])
    eeMat = vars.robot.arms[idx].out_frames[end]

    goal_quat = vars.goal_quats[idx]
    ee_quat = Quat(eeMat)

    ee_quat2 = Quat(-ee_quat.w, -ee_quat.x, -ee_quat.y, -ee_quat.z)

    disp = norm(quaternion_disp(goal_quat, ee_quat))
    disp2 = norm(quaternion_disp(goal_quat, ee_quat2))

    x_val = min(disp, disp2)

    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function positional_noise_obj(x, vars, idx)
    vars.robot.arms[idx].getFrames(x[vars.robot.subchain_indices[idx]])
    goal = vars.goal_positions[idx] + vars.noise.arm_noise[idx].position + vars.noise.base_noise.position
    x_val = norm(vars.robot.arms[idx].out_pts[end] - goal)
    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function rotational_noise_obj(x, vars, idx)
    vars.robot.arms[idx].getFrames(x[vars.robot.subchain_indices[idx]])
    eeMat = vars.robot.arms[idx].out_frames[end]
    orilog = quaternion_log(vars.goal_quats[idx])
    goal_ori = orilog + vars.noise.arm_noise[idx].rotation
    goal_quat = quaternion_exp(goal_ori)
    ee_quat = Quat(eeMat)

    ee_quat2 = Quat(-ee_quat.w, -ee_quat.x, -ee_quat.y, -ee_quat.z)

    disp = norm(quaternion_disp(goal_quat, ee_quat))
    disp2 = norm(quaternion_disp(goal_quat, ee_quat2))

    x_val = min(disp, disp2)

    # return groove_loss(x_val, 0.,2.,.1,10.,2.)
    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function position_obj_1(x, vars)
    return position_obj(x, vars, 1)
end

function rotation_obj_1(x, vars)
    return rotation_obj(x, vars, 1)
end

function position_obj_2(x, vars)
    return position_obj(x, vars, 2)
end

function rotation_obj_2(x, vars)
    return rotation_obj(x, vars, 2)
end

function position_obj_3(x, vars)
    return position_obj(x, vars, 3)
end

function rotation_obj_3(x, vars)
    return rotation_obj(x, vars, 3)
end

function position_obj_4(x, vars)
    return position_obj(x, vars, 4)
end

function rotation_obj_4(x, vars)
    return rotation_obj(x, vars, 4)
end

function position_obj_5(x, vars)
    return position_obj(x, vars, 5)
end

function rotation_obj_5(x, vars)
    return rotation_obj(x, vars, 5)
end

function positional_noise_obj_1(x, vars)
    return positional_noise_obj(x, vars, 1)
end

function rotational_noise_obj_1(x, vars)
    return rotational_noise_obj(x, vars, 1)
end

function positional_noise_obj_2(x, vars)
    return positional_noise_obj(x, vars, 2)
end

function rotational_noise_obj_2(x, vars)
    return rotational_noise_obj(x, vars, 2)
end


function positional_noise_obj_3(x, vars)
    return positional_noise_obj(x, vars, 3)
end

function rotational_noise_obj_3(x, vars)
    return rotational_noise_obj(x, vars, 3)
end

function positional_noise_obj_4(x, vars)
    return positional_noise_obj(x, vars, 4)
end

function rotational_noise_obj_4(x, vars)
    return rotational_noise_obj(x, vars, 4)
end

function positional_noise_obj_5(x, vars)
    return positional_noise_obj(x, vars, 5)
end

function rotational_noise_obj_5(x, vars)
    return rotational_noise_obj(x, vars, 5)
end

function joint_goal_obj(x, vars)
    goal, ret_k = interpolate_to_joint_limits(vars.vars.xopt, vars.joint_goal, t=0.033, joint_velocity_limits=vars.robot.velocity_limits)
    x_val = euclidean(x, goal)
    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function min_jt_vel_obj(x, vars)
    # return groove_loss(norm(x - vars.vars.xopt), 0.0, 2.0, 0.1, 10.0, 2.0)
    return groove_loss(norm(x - vars.vars.xopt), 0.0, 2, 0.1, 10.0, 2)
end

function min_jt_accel_obj(x, vars)
    # return groove_loss(norm((vars.vars.xopt - vars.vars.prev_state) - (x - vars.vars.xopt)), 0.0, 2.0, 0.1, 10.0, 2.0)
    return groove_loss(norm((vars.vars.xopt - vars.vars.prev_state) - (x - vars.vars.xopt)),  0.0, 2, .1, 10.0, 2)
end

function min_jt_jerk_obj(x, vars)
    # return groove_loss( norm( ( (x - vars.vars.xopt) - (vars.vars.xopt - vars.vars.prev_state) ) - ( (vars.vars.xopt - vars.vars.prev_state) - (vars.vars.prev_state - vars.vars.prev_state2) ) ),  0.0, 2.0, 0.1, 10.0, 2.0   )
    return groove_loss( norm( ( (x - vars.vars.xopt) - (vars.vars.xopt - vars.vars.prev_state) ) - ( (vars.vars.xopt - vars.vars.prev_state) - (vars.vars.prev_state - vars.vars.prev_state2) ) ),  0.0, 2, .1, 10.0, 2  )
end


function joint_limit_obj(x, vars)
    sum = 0.0
    penalty_cutoff = 0.85
    a = 0.05 / (penalty_cutoff^50.)
    # penalty = 1.0
    # d = 8
    joint_limits = vars.vars.bounds
    for i = 1:vars.robot.num_dof
        l = joint_limits[i][1]
        u = joint_limits[i][2]
        # mid = (u + l) / 2.0
        # a = penalty / (u - mid)^d
        # sum += a*(x[i] - mid)^d
        r = (x[i] - l) / (u - l)
        n = 2.0 * (r - 0.5)
        sum += a*n^50.
    end

    x_val = sum
    # return groove_loss(  x_val, 0.0, 2.0, 2.3, 0.003, 2.0 )
    return groove_loss(  x_val, 0.0, 2, 0.3295051144911304, 0.1, 2)
end

function collision_nn_obj(x, vars)
    state_to_joint_pts_inplace(x, vars)
    # state = state_to_joint_pts_withreturn(x, vars)
    # return groove_loss(  vars.nn_model( vars.joint_pts ) , 0.0, 2.0, 0.07, 100.0, 2.0 )
    # 0.2010929597597385, 0.5241930016229932, 1.1853951273805203
    # 0.2010929597597385, 0.5241930016229932, 1.1853951273805203
    # return groove_loss(  vars.nn_model( vars.joint_pts ) , 0.2010929597597385, 2, 0.52419, 1.1853951273805203, 2 )
    return groove_loss(  vars.nn_model3( vars.joint_pts ), vars.nn_t3, 2, vars.nn_c3, vars.nn_f3, 2 )
end



function bimanual_line_seg_collision_avoid_obj(x, vars)
    vars.robot.arms[1].getFrames(x[vars.robot.subchain_indices[1]])
    vars.robot.arms[2].getFrames(x[vars.robot.subchain_indices[2]])

    out_pts1 = vars.robot.arms[1].out_pts
    out_pts2 = vars.robot.arms[2].out_pts

    x_val = 0.0
    for i = 1:length(out_pts1)-1
        # x_val += (-2.718281828459^((-(out_pts1[i][3])^2) / (2.0 * c^2.0)) )
        # x_val += (-2.718281828459^((-(out_pts1[i+1][3])^2) / (2.0 * c^2.0)) )
        # for j = 1:length(out_pts2)-1
        c = 0.12
        dis1 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[1], out_pts2[2] )
        dis2 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[2], out_pts2[3] )
        dis3 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[3], out_pts2[4] )
        dis4 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[4], out_pts2[5] )
        dis5 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[5], out_pts2[6] )
        dis6 = dis_between_line_segments( out_pts1[i], out_pts1[i+1], out_pts2[6], out_pts2[7] )

        x_val += (2.718281828459^((-(dis1)^2) / (2.0 * c^2.0)) )
        x_val += (2.718281828459^((-(dis2)^2) / (2.0 * c^2.0)) )
        x_val += (2.718281828459^((-(dis3)^2) / (2.0 * c^2.0)) )
        x_val += (2.718281828459^((-(dis4)^2) / (2.0 * c^2.0)) )
        x_val += (2.718281828459^((-(dis5)^2) / (2.0 * c^2.0)) )
        x_val += (2.718281828459^((-(dis6)^2) / (2.0 * c^2.0)) )

            # the next two are just to avoid the plane on the ground
            # x_val += (-2.718281828459^((-(out_pts2[j][3])^2) / (2.0 * c^2.0)) )
            # x_val += (-2.718281828459^((-(out_pts2[j+1][3])^2) / (2.0 * c^2.0)) )
        # end
    end

    return groove_loss(x_val, 0.,2.,.2, .4, 2.)
end

function relative_position_objective(x, vars; idx1=4, idx2=5, goal_dist=0.15)
    # For the time being, hard code as the last two end effectors

    vars.robot.arms[idx1].getFrames(x[vars.robot.subchain_indices[idx1]])
    vars.robot.arms[idx2].getFrames(x[vars.robot.subchain_indices[idx2]])
    dist = norm(vars.robot.arms[idx1].out_pts[end] - vars.robot.arms[idx2].out_pts[end])
    x_val = norm(goal_dist-dist)

    return groove_loss(x_val, 0., 2, .1, 10., 2)
end

function orientation_match_objective(x, vars; idx1=4, idx2=5)
    # For the time being, hard code as the last two end effectors
    vars.robot.arms[idx1].getFrames(x[vars.robot.subchain_indices[idx1]])
    vars.robot.arms[idx2].getFrames(x[vars.robot.subchain_indices[idx2]])
    println("got frames")
    eeMat1 = vars.robot.arms[idx1].out_frames[end]
    eeMat2 = vars.robot.arms[idx2].out_frames[end]
    println("mat1: $eeMat1")
    println("mat2: $eeMat2")
    ee_quat1 = Quat(eeMat1)
    ee_quat2 = Quat(eeMat2)
    println("quat1: $ee_quat1")
    println("quat2: $ee_quat2")
    disp1 = norm(quaternion_disp(goal_quat, ee_quat1))
    disp2 = norm(quaternion_disp(goal_quat, ee_quat2))
    println("disp1: $disp1")
    println("disp2: $disp2")
    x_val = min(disp1, disp2)
    println("x_val: $x_val")

    return groove_loss(x_val, 0., 2, .1, 10., 2)
end
