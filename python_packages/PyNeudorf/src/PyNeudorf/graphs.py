import numpy as np
import networkx as nx
import scipy
import math
import random

def flat_upper_tri_regions_n(flat_upper_tri_len):
    """Get number of regions in original matrix from number of cells in upper triangle (only valid for square matrix)
    Derived by solving for x in y = (x)*(x-1)/2 where x is the number of regions and y is the number of cells in the upper triangle
    Parameters
    ----------
    flat_upper_tri_len  :   int
                            must be positive
    Returns
    -------
    original_regions_n:   int
    """
    original_regions_n = 1/2 + math.sqrt(1/4 + 2*flat_upper_tri_len)
    return int(original_regions_n)

def matrix_to_flat_triu(matrix):
    """Take numpy matrix and get flat upper triangle
    Parameters
    ----------
    matrix              :   ndarray
                            square adjacency matrix
    Returns
    -------
    triu                :   1-D ndarray with all cells in upper triangle
    """
    regions_n = matrix.shape[0]
    triu = matrix[np.triu_indices(regions_n,k=1)]
    return triu


def flat_to_square_matrix(triu_flat):
    """Load flattened upper triangle from txt and reshape to square matrix
    Parameters
    ----------
    triu_flat           :   1-D ndarray
                            flattened upper triangle data
    Returns
    -------
    matrix                 :   2-dimensional square ndarray
    """
    regions_n = flat_upper_tri_regions_n(triu_flat.size)
    matrix = np.zeros((regions_n,regions_n))
    matrix[np.triu_indices(regions_n,k=1)] = triu_flat.copy()
    matrix += matrix.T
    return matrix

def threshold_matrix(matrix,thresh,thresh_direction):
    """Take in `matrix` and threshold according to `thresh`, in the direction indicated by `thresh_direction`
    Parameters
    ----------
    matrix              :   ndarray
    thresh              :   float, positive (even if using neg thresh_direction, will switch to -1*thresh in function)
    thresh_direction    :   string
                            'pos'   :   positive, will set all values less than thresh to 0.0
                            'neg'   :   negative, will set all values greater than thresh to 0.0
                            'both'  :   positive and negative, will set all values between -thresh and +thresh to 0.0
    Returns
    -------
    matrix_thresholded  :   ndarray
    """
    matrix_thresholded = np.zeros_like(matrix)
    if thresh_direction == 'both':
        matrix_thresholded[np.where(matrix >= thresh)] = np.copy(matrix[np.where(matrix >= thresh)])
        matrix_thresholded[np.where(matrix <= -1*thresh)] = np.copy(matrix[np.where(matrix <= -1*thresh)])
    elif thresh_direction == 'pos':
        matrix_thresholded[np.where(matrix >= thresh)] = np.copy(matrix[np.where(matrix >= thresh)])
    elif thresh_direction == 'neg':
        matrix_thresholded[np.where(matrix <= -1*abs(thresh))] = np.copy(matrix[np.where(matrix <= -1*abs(thresh))])
    return matrix_thresholded

def stride_diag_remove(matrix):
    """This function removes the diagonal and shifts the upper right triangle to the left
    New dimensions will be (regions_n,regions_n-1)
    Parameters
    ----------
    matrix              :   2-D square ndarray
    Returns
    -------
    out                 :   2-D (regions_n-1,regions_n)
    """
    regions_n = matrix.shape[0]
    strided = np.lib.stride_tricks.as_strided
    s0,s1 = matrix.strides
    out = strided(matrix.ravel()[1:], shape=(regions_n-1,regions_n), strides=(s0+s1,s1)).reshape(regions_n,-1)
    return out
